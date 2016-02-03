module Training
  class Course < ActiveRecord::Base

    attr_accessible :course_url, :ecatts_course_id, :tasks_user_id, :course_name, :course_start_date, :course_pass_date, :percent_complete, :course_certificate

    belongs_to :tasks_user, class_name: "TasksUser"
		has_one :user, through: :tasks_user
		has_one :task, through: :tasks_user
    has_one :certificate

    def self.build_from_template(course_template, tasks_user_id)
      course = self.new(course_name: course_template.course_name,
                        course_start_date: course_template.course_start_date,
                        ecatts_course_id: course_template.ecatts_course_id,
                        tasks_user_id: tasks_user_id,
                        course_url: course_template.course_url)
      course.course_url += "&user_id=#{tasks_user_id}"
      course.course_url += "&course_id=#{course_template.ecatts_course_id}"
      course
    end

    def complete!(pass_date)
      self.course_pass_date = pass_date
			self.percent_complete = 100
      self.save!
      self.certificate = Certificate.create(awarded_date: self.course_pass_date, tasks_user_id: tasks_user.id, course_id: self.id, fullname: user.fullname, course_name: self.course_name)
    end

    def complete?
      self.course_pass_date ? true : false
    end

    def link?
      course.course_url ? true : false
    end

		def uncomplete(destroy_certificate = nil)
      self.course_pass_date = nil
			self.percent_complete = nil
      self.save!
			self.certificate.delete if destroy_certificate
		end

  end
end
