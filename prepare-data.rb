require 'langchain'
require 'weaviate'
require 'openai'
require 'colorize'
require 'highline'
require 'fileutils'
require "dotenv/load"
require 'aws-sdk'

require 'pry'

def extract_text(local_file)
  # Set your AWS credentials and region
  Aws.config.update({
    region: 'eu-central-1',
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  })

  # Create a new S3 Client
  s3_client = Aws::S3::Client.new

  # Create a Textract client
  textract_client = Aws::Textract::Client.new

  # Specify the S3 bucket and file key for the PDF document
  s3_bucket = 'pdf-chat-files'
  s3_object_key = File.basename(local_file)

  # Upload the local PDF file to the S3 bucket
  File.open(local_file, 'rb') do |file|
    s3_client.put_object({
      bucket: s3_bucket,
      key: s3_object_key,
      body: file
    })
  end

  # Start the Textract job
  response = textract_client.start_document_text_detection({
    document_location: {
      s3_object: {
        bucket: s3_bucket,
        name: s3_object_key
      }
    }
  })

  # Get the job ID
  job_id = response.job_id

  job_status = "UNDEFINED"

  # Poll for the job status
  loop do
    # Get the status of the Textract job
    job_status = textract_client.get_document_text_detection({ job_id: job_id }).job_status

    print '.'.yellow

    # Check if the job is completed
    break if job_status == 'SUCCEEDED' || job_status == 'FAILED'

    # Wait for a short time before checking again
    sleep(2)
  end

  # Check if the job succeeded or failed
  if job_status == 'SUCCEEDED'
    # Get the results
    result = textract_client.get_document_text_detection({ job_id: job_id })

    # Extract text from the result
    text = result.blocks.map(&:text).join("\n")

    # Delete the S3 object again
    s3_client.delete_object({
      bucket: s3_bucket,
      key: s3_object_key
    })

    # Print the extracted text
    print 'o'.green

    return text
  else
    puts "Textract job failed for file #{File.basename(local_file)}. Check the Textract console for more details."
  end

end

def extract_texts_from_pdf_directory(directory)
  Dir["#{directory}/*"].each do |f|
    if File.file?(f) && File.readable?(f) && !File.exist?("txts/#{File.basename(f)}.txt")
      File.open("txts/#{File.basename(f)}.txt", 'w') do |textfile|
        textfile.write(extract_text(f))
      end      
    end
  end
end

def read_files_from_directory_into_array(directory)
  arr = []
  Dir["#{directory}/*"].each do |f|
    if File.file?(f) && File.readable?(f)
      arr << File.read(f).strip
      print 'o'.green
    end
  end
  return arr
end

def insert_into_weaviate
  # Instantiate the Weaviate client
  weaviate = Langchain::Vectorsearch::Weaviate.new(
    url: 'http://127.0.0.1:8080',
    api_key: '',
    index_name: "PDF1",
    llm: Langchain::LLM::OpenAI.new(
      api_key: ENV["OPENAI_API_KEY"],
      default_options: {
        completion_model_name: 'gpt-4-1106-preview',
        chat_completion_model_name: 'gpt-4-1106-preview'
      }
    )
  )

  # Create the default schema.
  weaviate.destroy_default_schema
  weaviate.create_default_schema

  # Add data to the index. Weaviate will use OpenAI to generate embeddings behind the scene.
  Dir['txts/*'].each do |f|
    if File.file?(f) && File.readable?(f)
      begin
        weaviate.add_texts(
          texts: File.read(f).strip
        )
        print '.'.green
      rescue Exception => e
        print " Error with file: #{f} ".red
      end
    end
  end
end

FileUtils.mkdir_p(['pdfs', 'txts'])

print 'Please wait, preparing your data...'.yellow

extract_texts_from_pdf_directory('pdfs')
insert_into_weaviate()

puts ' done'.green

