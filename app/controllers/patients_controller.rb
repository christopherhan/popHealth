require 'prawn'

class PatientsController < ApplicationController
  include MeasuresHelper

  before_filter :authenticate_user!
  before_filter :validate_authorization!
  before_filter :load_patient, :only => [:show, :toggle_excluded]
  after_filter :hash_document, :only => :list
  
  add_breadcrumb_dynamic([:patient], only: %w{show}) {|data| patient = data[:patient]; {title: "#{patient.last}, #{patient.first}", url: "/patients/show/#{patient.id}"}}
  
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
  
  def medications
    @meds = Record.get_medications      
  end
  
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
  
  def export_meds
    $meds = Record.get_medications
    Prawn::Document.generate "medications.pdf" do

      @rows = Array.new      
      @rows << ['<strong>RxNormID</strong>', '<strong>Count</strong>', '<strong>Name</strong>']
      
      define_grid(:columns => 5, :rows => 14, :gutter => 10)
      time = Time.new
      
      grid(0,0).bounding_box do
        image "#{Rails.root}/app/assets/images/logo_light.png", :width=>100, :position => -10, 
                                                                              :vposition => -10
      end
      
      grid([0,1],[0,4]).bounding_box do
        
        text "Medications List"
        font_size 8
        text "Generated on #{time.strftime("%B %d, %Y %I:%M %p")}"
        move_down 2
      end
      
      grid([1,0],[13,4]).bounding_box do
        font_size 10
        text "Total Medications: #{$meds.length}", :style => :bold
        font_size 8
        move_down 10
        $meds.each do |key, value|
          #puts key
          @row = [key, value['count'], value['name']]
          @rows << @row
        end
      
        table(@rows, :column_widths => [50, 50, 440], 
                     :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      end
    end
    redirect_to :back
  end  
  



  
  def export
    $patient = Record.find(params[:id])

    Prawn::Document.generate "#{$patient.last}_#{$patient.first}_#{$patient.patient_id}.pdf" do
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
        font_size 10
        text 'Provider Information', :style => :bold
        font_size 8
        move_down 2
        data = [['<strong>Health Plan:</strong>', 'Harvard Pilgrim'],
                 ['<strong>Policy #:</strong>', 'XXFJIEWO5'],
                 ['<strong>PCP:</strong>', 'Dr. Jimi Hendrix']]
        
        table(data, :column_widths => [70, 110], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      
      end
      
      grid([1,2], [3,4]).bounding_box do
        font_size 10
        text 'Patient Information', :style => :bold
        font_size 8
        move_down 2
        data = [ ['<strong>Address<strong>',"#{$patient.addresses[0]['street'][0]} \n" + 
                                            "#{$patient.addresses[0]['city']}, " +
                                            "#{$patient.addresses[0]['state']} " +
                                            "#{$patient.addresses[0]['postalCode']}",
                  '<strong>Language</strong>', 'English'
                 ],
                 ['<strong>DOB:</strong>', "#{Time.at($patient.birthdate).strftime('%d %b %Y')} (Age: 25)",
                  '<strong>Ethnicity:</strong>', 'Non-Hispanic'
                 ],
                 
                 ['<strong>Sex:</strong>', $patient.gender, 
                  '<strong>Race:</strong>', 'Asian'
                 ],
                 ['<strong>Blood Type:</strong>', 'O',
                  '<strong>Tobacco User:</strong>', 'No'
                  ]
               ]
                 
        table(data, :column_widths => [50, 110, 50, 110], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      
      end

      grid(3,0).bounding_box do
        font_size 10
        text 'Allergies', :style => :bold
        font_size 8
        move_down 2
        text "1. Penicilin \n 2. Benadryl", :inline_format => true
        #table(data, :column_widths => [50,50], 
        #            :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })   
      end

      grid([3,1], [6,1]).bounding_box do
        font_size 10
        text 'Vaccines', :style => :bold
        font_size 8
        move_down 5
        
        text "Tetanus", :style => :bold
        text "1. April 3, 2003\n"+
             "2. April 5, 2005"

        move_down 5
        text "TB", :style => :bold
        text "1. Incomplete"

        move_down 5
        text "MMR", :style => :bold
        text "1. Incomplete"

        move_down 5
        text "Hepatitis A", :style => :bold
        text "1. Incomplete"

        move_down 5
        text "Hepatitis B", :style => :bold
        text "1. Incomplete"

        move_down 5
        text "Diphtheria", :style => :bold
        text "1. Incomplete"

      end

      grid(4,0).bounding_box do
        font_size 10
        text 'Medications', :style => :bold
        font_size 8
        move_down 5
        
        text "1. Avapro \n 2. Advair", :inline_format => true
      end
      
      grid([5,0],[5,1]).bounding_box do
        font_size 10
        text 'Procedures', :style => :bold
        font_size 8
        move_down 5
        text '1. Nutrition Counseling'
      end

      grid([6,0], [6,1]).bounding_box do
        font_size 10
        text 'Diagnosis', :style => :bold
        font_size 8
        move_down 5
        text 'None'
      end
    
      grid([4,2], [6,4]).bounding_box do
        font_size 10
        text 'Physical Exam Findings', :style => :bold
        font_size 8
        move_down 5

        data = [
                ['', '<strong>Measurement</strong>', '<strong>Range</strong>'],
                ['Height', "5'9\"", ''],
                ['Weight', '159 LBS', '170-180'],
                ['BMI', '28 kg/m2', '<25'],
                ['Waist Circ.', '38 inches', '<40'],
                ['BP', '133.93 mmHg','']
               ]
        table(data, :column_widths => [70,100, 50], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" }) 
      end

      grid([7,2],[9,4]).bounding_box do
        font_size 10
        text 'Lab Results', :style => :bold
        font_size 8
        move_down 5

        data = [
                ['', '', '<strong>Measurement</strong>', '<strong>Range</strong>'],
                ['Cholesterol', 'Total', '223 mg/dl', '100-199'],
                ['', 'LDL', '171 mg/dl', '40-130'],
                ['', 'HDL', '41 mg/dl', '40-70'],
                ['Triglycerides', '', '66 mg/dl', '70-137'],
                ['Glucose','', '99 mg/dl','72-137']
               ]
        table(data, :column_widths => [70, 50, 100, 50], 
                    :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      end
        
      grid([10,2], [11,4]).bounding_box do
        font_size 10
        text 'Encounters', :style => :bold
        font_size 8
        move_down 5

        data = [
                ['<strong>Time</strong>', '<strong>Description</strong>'],
                ['10/19/09', 'Outpatient Encounter'],
                ['08/10/08', 'Prenatal Visit 1']
               ]
        table(data, :column_widths => [70,120], 
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