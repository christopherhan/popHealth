require 'prawn'

class PatientsController < ApplicationController
  include MeasuresHelper

  before_filter :authenticate_user!
  before_filter :validate_authorization!
  before_filter :load_patient, :only => [:show, :toggle_excluded]
  after_filter :hash_document, :only => :list
  
  add_breadcrumb_dynamic([:patient], only: %w{show}) {|data| patient = data[:patient]; {title: "#{patient.last}, #{patient.first}", url: "/patients/show/#{patient.id}"}}
  
  def list
    measure_id = params[:id] 
    sub_id = params[:sub_id]
    @records = mongo['patient_cache'].find({'value.measure_id' => measure_id, 'value.sub_id' => sub_id,
                                            'value.effective_date' => @effective_date}).to_a
    # log the patient_id of each of the patients that this user has viewed
    @records.each do |patient_container|
      authorize! :read, patient_container
      Log.create(:username =>   current_user.username,
                 :event =>      'patient record viewed',
                 :patient_id => (patient_container['value'])['medical_record_id'])
    end
    respond_to do |format|
      format.xml do
        headers['Content-Disposition'] = 'attachment; filename="excel-export.xls"'
        headers['Cache-Control'] = ''
        render :content_type => "application/vnd.ms-excel"
      end
      
      format.html {}
    end
  end

  def show
  end
  
  def search
    if params[:fn] or params[:ln]
      @results = Record.where(:first => /^(#{params[:fn]})/i).or(:last => /^(#{params[:ln]})/i)
    end 
  end
  
  def toggle_excluded
    ManualExclusion.toggle!(@patient, params[:measure_id], params[:sub_id], params[:rationale], current_user)
    redirect_to :controller => :measures, :action => :patients, :id => params[:measure_id], :sub_id => params[:sub_id]
  end
  
  def export
    $patient = Record.find(params[:id])

    Prawn::Document.generate "explicit.pdf" do
      define_grid(:columns => 5, :rows => 14, :gutter => 10)
      time = Time.new
      #grid.show_all
      grid(0,0).bounding_box do
        image "#{Rails.root}/app/assets/images/logo_light.png", :width=>100, :position => -10, 
                                                                             :vposition => -10
      end 
      
      grid([0,1],[0,4]).bounding_box do
        text "Patient Information for #{$patient.first} #{$patient.last}"
        font_size 8
        text "Generated on #{time.strftime("%B %d, %Y %I:%M %p")}"
        move_down 2
        text "Effective date 10/19/2009"
      end
      grid([1,0], [2,1]).bounding_box do
        data = [['<strong>Health Plan:</strong>', 'Harvard Pilgrim'],
                 ['<strong>Policy #:</strong>', '9234890'],
                 ['<strong>PCP:</strong>', 'Dr. Jimi Hendrix']]
        
        table(data, :column_widths => [70, 110], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      
      end
      
      grid([1,2], [2,3]).bounding_box do
        
        data = [['<strong>DOB:</strong>', 'June 19, 1986 (Age: 25)'],
                 ['<strong>Sex:</strong>', 'M'], 
                 ['<strong>Race:</strong>', 'Asian']]
                 
        table(data, :column_widths => [50, 110], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      
      end
      
    end
    redirect_to :back
  end
  
  private
  
  def load_patient
    @patient = Record.find(params[:id])
    authorize! :read, @patient
  end

  def validate_authorization!
    authorize! :read, Record
  end

end