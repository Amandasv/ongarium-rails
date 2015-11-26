class InterestsController < ApplicationController  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
	def new
		@interest = Interest.new
		@interest.build_volunteer
	end

def create
	@interest = Interest.new(interest_params)
	respond_to do |format|
		if @interest.save
			VolunteerMailer.volunteer_email(@interest.volunteer, @interest.opportunity).deliver_later
			NgoMailer.ngo_email(@interest.volunteer, @interest.opportunity).deliver_later
			format.html { redirect_to @interest.opportunity, notice: 'Interesse registrado com sucesso' }
		else
			format.html { render :new }
		end
	end
end

private
    def interest_params
    	params.require(:interest).permit(:opportunity_id, :volunteer_attributes => [:name, :email, :phone, :observations])
    end
end