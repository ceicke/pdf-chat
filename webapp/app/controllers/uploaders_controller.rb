class UploadersController < ApplicationController

  def new
  end

  def create
    name = params[:file].original_filename
    path = Rails.configuration.pdf_storage + '/' + name

    File.open(path, "wb") { |f| f.write(params[:file].read) }

    redirect_to new_uploader_path, notice: 'Datei hochgeladen'
  end

end
