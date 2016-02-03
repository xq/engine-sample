module Training
	require 'training/certificate_renderer'
  class CoursesController < ApplicationController
    
    include HTTParty

    before_filter :required_update_params, :only => :update
    before_filter :required_complete_params, :only => :show
    skip_before_filter :verify_authenticity_token, only: [:status]

    def update
      response = Hash.from_xml(params['xml'])['response']
			tasks_user = TasksUser.where(id: response['user_id']).first
      course = Course.where(tasks_user_id: tasks_user, ecatts_course_id: response['course_id']).first
      unless course && course.complete?
				complete_training(course, response)
      end
      render text: "ok", status: 200 and return
    end

    def new
      action = ActionButton.find_by_key(params[:key])
      @tasks_user = TasksUser.where(id: action.tasks_user_id).first
      render :already_complete, layout: false and return if @tasks_user.completed?
      @task = @tasks_user.task.decorate
      @course_url = @task.course_link_md5(@tasks_user.id)
      @course = Course.where(tasks_user_id: @tasks_user.id).first
      render :new
    end

    def show
			tasks_user_ids = TasksUser.where(user_id: current_user.id).map {|tu| tu.id}
      @course = Course.where(course_id: params[:course_id]).where('tasks_user_id IN (?)', tasks_user_ids)
      render :show
    end

    def status
      response = { response: "error" }
      if params[:id]
        course = Course.where(id: params[:id]).first
        render json: response and return unless course
        response[:response] = course.complete? ? "complete" : "incomplete"
      end
      render json: response
    end

    def certificate
      return unless params[:course] && params[:user]
      course = Course.where(id: params[:course]).first
      send_data(course.certificate.generate, :filename => "certificate.pdf", :type => "application/pdf") 
    end

    def complete
      return render :complete, layout: false
    end


    private

			def complete_training(course, response)
				course.complete!(response['course_complete_date'])
				task = course.task
				tasks_user = task.tasks_users.where(id: course.tasks_user_id).first
				response_handler = Emails::ResponseHandlers::Task::Complete.new(tasks_user, '', '', '', '')
				response_handler.complete_open
			end

      def required_update_params
        unless params.has_key?(:type) && params.has_key?(:xml)
          render text: "Missing paramaters", status: 400 and return false
        end
        true
      end
      alias_method :required_complete_params, :required_update_params
  end

end
