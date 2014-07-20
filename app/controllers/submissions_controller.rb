class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @challenge = Challenge.find_by!(slug: params[:challenge_slug])
    if current_user.instructor?
      @submissions = @challenge.submissions
    else
      @submissions = @challenge.submissions.where(user: current_user)
    end
  end

  def show
    if current_user.instructor?
      @submission = Submission.find_by(id: params[:id]) || not_found
    else
      @submission = current_user.submissions.
        find_by(id: params[:id]) || not_found
    end

    @comment = Comment.new
  end

  def new
    @challenge = Challenge.find_by!(slug: params[:challenge_slug])
    @submission = Submission.new
  end

  def create
    @challenge = Challenge.find_by!(slug: params[:challenge_slug])
    @submission = @challenge.submissions.build(submission_params)
    @submission.user = current_user

    if @submission.save
      flash[:info] = "Solution submitted."
      redirect_to submission_path(@submission)
    else
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:body, :archive)
  end
end