class NgosController < ApplicationController
	before_action :set_ngo, only: [:show]

	def new
		@ngo = Ngo.new
		@ngo.build_address
	end

	def index
		@ngos_result = Ngo.all.includes(:address).page params[:page]
	end

	def show
	end

	private 
    def set_ngo
      if Ngo.where(:id => params[:id]).present?
        @ngo = Ngo.find(params[:id])
      else
        redirect_to "/404"
      end
    end

	def create
		@ngo = Ngo.new(ngo_params)

		respond_to do |format|
			if(@ngo.save)
				NgoMailer.email_confirmation(@ngo).deliver
				format.html { redirect_to @ngo, notice: "ONG cadastrada com sucesso, confirme o email para continuar" }
			else
				render 'new'
			end
		end
	end

	def confirm_email
		@ngo = Ngo.find_by_confirm_token(params[:id])
		respond_to do |format|
			if @ngo != nil
				@ngo.email_activate
				format.html { redirect_to @ngo, notice: "Email cadastrado com sucesso, bem vindo ao ONGARIUM." }
			else
				format.html { redirect_to root_path, notice: "Falha, a ONG não existe." }
			end
		end
	end

	private
		def ngo_params
			params.require(:ngo).permit(:name, :description, :email, :address_attributes => [:address, :cep, :complement, :state, :city, :country, :neighbourhood])
		end
end

