module Training
  class CourseTemplate < ActiveRecord::Base
    attr_accessible :account_id, :course_end_date, :ecatts_course_id, :course_name, :course_start_date, :course_url

    has_and_belongs_to_many :task_templates, class_name: "TaskTemplate"

  end
end
