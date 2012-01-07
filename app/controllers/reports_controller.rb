require 'prawn'
class ReportsController < ApplicationController
  include ReportsHelper

  skip_authorization_check
  before_filter :authenticate_user!
  def index
  
  end

  def measure_report
    selected_measures = mongo['selected_measures'].find({:username => current_user.username}).to_a
    
    @report = {}
    @report[:registry_name] = current_user.registry_name
    @report[:registry_id] = current_user.registry_id
    @report[:provider_reports] = []
    params[:type] = 'practice' 
    case params[:type]
    when 'practice'
      authorize! :manage, :providers
    end


    
    Prawn::Document.generate "quality.pdf" do
      def subs_iterator(measure_subs)
        subs = nil
        if measure_subs.empty?
            subs = [nil]
        else
            subs = measure_subs
        end
        subs.each do |sub_id|
            yield sub_id
        end
      end
      def extract_result(id, name, description, sub_id, effective_date, providers=nil)
        if (providers)
          qr = QME::QualityReport.new(id, sub_id, 'effective_date' => effective_date, 'filters' => {'providers' => providers})
        else
          qr = QME::QualityReport.new(id, sub_id, 'effective_date' => effective_date)
        end
        qr.calculate(false) unless qr.calculated?
        result = qr.result
        {
          :id=>id,
          :sub_id=>sub_id,
          :name=>name,
          :description=>description,
          :population=>result['population'],
          :percent => result['denominator'] == 0 ? 0 : (result['numerator'].to_f / result['denominator']) * 100,
          :denominator=>result['denominator'],
          :numerator=>result['numerator'],
          :exclusions=>result['exclusions']
        }
      end

      $doc = {}
      $doc[:start] = Time.at(519541200)
      $doc[:end] = Time.now
      $doc[:npi] = @provider ? @provider.npi : '' 
      $doc[:tin] = @provider ? @provider.tin : ''
      $doc[:results] = []
    
      selected_measures.each do |measure|
        subs_iterator(measure['subs']) do |sub_id|
          $doc[:results] << extract_result(measure['id'], measure['name'], measure['description'], sub_id, 1291183200, false)
        end
      end

      @rows = Array.new      
      @rows << ['<strong>Row</strong>','<strong>RxNormID</strong>', '<strong>Count</strong>', '<strong>Name</strong>']
      
      define_grid(:columns => 5, :rows => 14, :gutter => 10)
      time = Time.new
      
      grid(0,0).bounding_box do
        image "#{Rails.root}/app/assets/images/logo_light.png", :width=>100, :position => -10, 
                                                                              :vposition => -10
      end
      
      grid([0,1],[0,4]).bounding_box do
        
        text "Selected Measures"
        font_size 8
        text "Generated on #{time.strftime("%B %d, %Y %I:%M %p")}"
        move_down 2
      end
 
      grid([1,0], [2,1]).bounding_box do
        text "Start Date: #{$doc[:start]}"
        move_down 2
        text "End Date: #{$doc[:end]}"
        move_down 2
        text "NPI: #{$doc[:npi]}"
        move_down 2
        text "TIN: #{$doc[:tin]}"
      end

      grid([2,0], [13,4]).bounding_box do
        @rows = Array.new      
        @rows << ['<strong>ID</strong>',
                  '<strong>SubID</strong>', 
                  '<strong>Name</strong>', 
                  '<strong>%</strong>', 
                  '<strong>Numerator</strong>',
                  '<strong>Denominator</strong>',
                  '<strong>Exclusions</strong>',
                  '<strong>Population</strong>']

        $doc[:results].each do |result|
            @row = [result[:id], 
                    result[:sub_id], 
                    result[:name], 
                    (sprintf "%.2f", result[:percent]), 
                    result[:numerator], 
                    result[:denominator], 
                    result[:exclusions], 
                    result[:population]]

            @rows << @row
        end

        table(@rows, :column_widths => [30, 40, 150, 50, 50, 65, 55, 55], 
                     :cell_style => { :inline_format => true, :border_width => 0.5, :border_color => "EEEEEE" })
      end

    end
    redirect_to :back
  end 
end
