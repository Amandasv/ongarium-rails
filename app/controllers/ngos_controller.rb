class NgosController < ApplicationController
	before_action :set_ngo, only: [:show]

	def new
		@ngo = Ngo.new
    finder = Correios::CEP::AddressFinder.new
		@ngo.build_address
		@ngo.build_user
    @ngo.phones.build

     respond_to do |format|
      if request.xhr? 
        if params[:zipcode] 
          @address = Address.new(Correios::CEP::AddressFinder.get(params[:zipcode]))
          format.json
        end
      else
        format.html
      end
    end
	end

	def index
		@ngos_result = Ngo.all.includes(:address, :user).page params[:page]
	end

	def show
	end

	def create
    @ngo = Ngo.new(ngo_params)
    @ngo.user.role = "ngo"  
    respond_to do |format|  
      if(ngo_exists?(ngo_params[:name],ngo_params[:user_attributes][:email]))
        format.html { render 'new' }  
    	elsif(@ngo.save)
        set_ngo_list_phones(ngo_params[:phones_attributes]) if ngo_params[:phones_attributes] != nil
    		UserMailer.email_confirmation(@ngo).deliver
    		format.html { redirect_to @ngo, notice: "ONG cadastrada com sucesso, confirme o email para continuar" }
    	else
    			format.html { render 'new' }
    	end      
    end
  end

	private 
    def set_ngo
      if Ngo.where(:id => params[:id]).present?
        @ngo = Ngo.find(params[:id])
      else
        redirect_to "/404"
      end
    end

		def ngo_params
			params.require(:ngo).permit(:user_id, :name, :description, :privacy, :address_attributes => [:address, :zipcode, :complement, :state, :city, :country, :neighborhood], :user_attributes => [:email, :password, :password_confirmation], :phones_attributes => [:phone_number])
		end

    def ngo_exists?(ngo_name, email)
      if(User.find_by_email(email) != nil)
        flash[:error] = "Erro. Email já existe!"
        return true
      elsif(Ngo.find_by_name(ngo_name) != nil)
        flash[:error] = "Erro. Ong já existe!"
        return true
      end
      return false
    end


    def set_ngo_list_phones(phones_list)
      phones_list.each do |x, phone|
        if(phone[:phone_number] != "")
          new_phone = Phone.new(phone_number: phone[:phone_number], ngo_id: @ngo.id)
          new_phone.save
        end
      end
    end

end

