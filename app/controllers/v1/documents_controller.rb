

module V1
  class DocumentsController < ApplicationController
    before_action :get_document, only: %i[show update destroy]

    def index
      require_admin
      document = Document.where(access: 0).or(
        Document.where(user_id: current_user.id)
      )
      document = document.page(params[:page]).per(params[:per_page] || 5)
      json_response(status: :ok, object: document)
    end

    def my_documents
      my_documents = current_user.documents
      my_documents = my_documents.page(params[:page]).per(params[:per_page] || 5)
      json_response(status: :ok, object: my_documents)
    end

    def create
      document = current_user.documents.create!(document_params)
      json_response(
        status: :created,
        object: document,
        message: Message.document_created
      )
    end

    def show
      if @document.personal?
        unathorize_current_user_error(@document.user)
      end
      json_response(status: :ok, object: @document)
    end

    def update
      unathorize_current_user_error(@document.user)
      document = current_user.documents.find(@document.id)
      document.update(document_params)
      json_response(
        status: :ok,
        object: @document.reload,
        message: Message.document_updated
      )
    end

    def destroy
      unathorize_current_user_error(@document.user)
      @document.destroy!
      json_response_default(status: :ok, message: Message.document_deleted)
    end

    private

    def get_document
      @document = Document.find(params[:id])
    end

    def document_params
      params.permit(:title, :access, :content)
    end
  end
end
