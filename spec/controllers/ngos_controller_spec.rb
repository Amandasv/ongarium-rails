require 'rails_helper'

describe NgosController, type: :controller do
  describe '#index' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      user3 = User.create!(email:"twe321@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, name:"nome1", description: "Qualquer coisa1",user_id:user.id)
      @ngo2 = Ngo.create!(address_id: address.id, name:"nome2", description: "Qualquer coisa2",user_id:user2.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: address.id, name:"nome_new", description: "Qualquer coisa",user:user_new)
      @ngo_private = Ngo.create!(address_id: address.id, name: "qualquer ai", description: "brbrbr", user_id:user3.id, privacy: true)
      @controller = NgosController.new
    end

    it 'show all results when index' do
      get :index
      expect(assigns[:ngos_result]).to match_array([@ngo, @ngo2, @ngo_private])
    end

    it 'expect if Ngo privacy is true to have a new Address' do
      get :show, id: @ngo_private.id
      expect(assigns(:ngo).address).to be_a_new(Address)
    end

    it 'expect redirect to 404 if ngo isnt present' do
      get :show, id: -20
      expect(response).to redirect_to('/404')
    end

    it 'returns true when passing a ngos existing name' do
      expect(@controller.ngo_exists?(@ngo)).to be true
    end

    it 'returns true when passing a ngos existing email' do
      expect(@controller.ngo_exists?(@ngo)).to be true
    end

    it 'returns false when a new ngo is passed' do
      expect(@controller.ngo_exists?(@ngo_new)).to be false
    end

    it 'returns false when ngo was deleted' do
      @ngo.user.email = nil
      @ngo.user.role = nil
      @ngo.destroy
      expect(@controller.ngo_exists?(@ngo)).to be false
    end
  end

    describe '#create' do
      before :each do
        address = Address.create!(city:"POA", zipcode: "5", address:"rua")
        user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
        user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
        @ngo = Ngo.create!(address_id: address.id, name:"nome1", description: "Qualquer coisa1",user_id:user.id)
        @ngo2 = Ngo.create!(address_id: address.id, name:"nome2", description: "Qualquer coisa2",user_id:user2.id)
      end

    it 'return success if NGO was created' do
      mailer = instance_double("mailer", deliver: "enviou")
      allow(UserMailer).to receive(:email_confirmation) { mailer }
      post :create, {ngo: 
        {
        name:"ABC", 
        description:"Abobora", 
        privacy: true, 
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"},
        phones_attributes: {"1"=>{phone_number:"123456789"} }
        }
      }
        expect(flash[:notice]).to eq("ONG cadastrada com sucesso, confirme o email para continuar")
    end

    it 'return error if ngo exists' do
      post :create, {ngo: {
        name:"nome1",
        description:"Qualquer coisa1",
        privacy: true,
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"},
        phones_attributes: {"1"=>{phone_number:"123456789"} }
        }
      }
      expect(flash[:error]).to eq("ONG já cadastrada!")
    end

      it 'render new if anything goes wrong' do
      post :create, {ngo: {
        name: nil,
        description:"Qualquer coisa1",
        privacy: true,
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"},
        phones_attributes: {"1"=>{phone_number:"123456789"} }
        }
      }
      expect(response).to render_template("new")
    end
  end

  describe '#edit' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, name:"nome", description: "Qualquer coisa",user_id:@user.id)
    end

    it 'finds ngo when ID is correct' do
      cookies[:auth_token] = @ngo.user.auth_token
      get :edit, id: @ngo.id
      expect(assigns(:ngo)).to eq(@ngo)
    end

    ## NÂO FUNCIONA
    # it 'abc' do
    #   cookies[:auth_token] = @ngo.user.auth_token
    #   get :edit, id: @ngo.id, zipcode: '90840-030'
    #   expect(JSON.parse(response.body)).to eq('1231')
    # end
  end

  describe '#update' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, name:"nome", description: "Qualquer coisa",user_id:@user.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: address.id, name:"nome_new", description: "Qualquer coisa",user:user_new)
    end

    it 'return success when ngo is updated' do
      put :update, 
      {
        id: @ngo.id, ngo: 
        {
          name:"ONG atualizada", description:"ae", privacy:false, 
          address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado"}          
        }
      }     
      expect(flash[:notice]).to eq("ONG atualizada com sucesso") 
    end

    it 'render edit if fails and show "Error" on notice' do
      put :update, 
      {
        id: @ngo.id, ngo: 
        {
          name:"ONG atualizada", description:"ae", privacy:false, 
          address_attributes: {zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado"}          
        }
      }
      expect(response).to render_template('edit')
    end 
  end

  describe '#destroy' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, name:"nome", description: "Qualquer coisa",user_id:@user.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: address.id, name:"nome_new", description: "Qualquer coisa",user:user_new)
    end

     it 'return success when the NGO was deleted' do
       cookies[:auth_token] = @ngo.user.auth_token
       delete :destroy, id: @ngo.id
       expect(flash[:notice]).to eq("A ONG foi removida com sucesso")
     end
  end
  
  describe '#new' do
    it 'expect ngo be a instance of Ngo' do
      get :new
      expect(assigns(:ngo)).to be_a_new(Ngo)
    end
  end
end