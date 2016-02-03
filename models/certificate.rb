module Training
  require 'training/certificate_renderer'
  class Certificate < ActiveRecord::Base
    attr_accessible :cid, :course_name, :course_id, :tasks_user_id, :fullname, :awarded_date

    belongs_to :course
    belongs_to :tasks_user, class_name: "TasksUser"

    after_create :generate_token

    def generate
      ::Training::CertificateRenderer.new(self).render
    end

    private

      def generate_token
				certificate_id = SecureRandom.hex(16).upcase
        self.update_attributes(cid: certificate_id)
      end

  end
end
