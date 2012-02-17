require 'rest_client'
require 'set'
include ActionView::Helpers::DateHelper

class Record
  include Mongoid::Document  
  
  field :first, type: String
  field :last, type: String
  field :patient_id, type: String
  field :birthdate, type: Integer
  field :patient_id, type: String
  field :gender, type: String
  field :measures, type: Hash
  
  embeds_many :provider_performances
  
  scope :with_provider, where(:provider_performances.ne => nil).or(:provider_proformances.ne => [])
  scope :without_provider, any_of({provider_performances: nil}, {provider_performances: []})
  scope :by_provider, ->(prov, effective_date) { (effective_date) ? where(provider_queries(prov.id, effective_date)) : where('provider_performances.provider_id'=>prov.id)  }
  scope :by_patient_id, ->(id) { where(:patient_id => id) }
  scope :provider_performance_between, ->(effective_date) { where("provider_performances.start_date" => {"$lt" => effective_date}).and('$or' => [{'provider_performances.end_date' => nil}, 'provider_performances.end_date' => {'$gt' => effective_date}]) }
  
  def self.get_medications
    @rxnorm = Hash.new()
    Record.all.each do |record|
      if record.medications.any?
        record.medications.each do |med|
          @key = med['codes']['RxNorm']
          unless key.nil? or key.empty? or key.blank?
            @rxnorm.has_key?(@key) ? @rxnorm[@key] += 1 : @rxnorm[@key] = 1
          end
        end
      end
    end   
    
    # uncomment to query API
    #@meds = Array.new
    #@rxnorm.each do|code, count|
    #  unless code.nil?
    #    @res = RestClient.get "http://rxnav.nlm.nih.gov/REST/rxcui/#{code[0]}", { :accept => :json }
    #    @meds << @res
    #  end
    #end
    
    
    @medications = Hash.new
    @rxnorm.each do|code, count|
      unless code.nil? or code.empty? or code.blank?
        @med = Medication.where(rxnormId: code[0])
        @med.each do |m|
          @medications[m.rxnormId] = {'count'=> @rxnorm[Array[code[0]]], 'name' => m.name } #TODO remove array by checking for nil above
        end
      end
    end
    return @medications
  end
 
  def self.get_conditions
    @counts = Hash.new
    @conditions = Hash.new
    @with_condition = Set.new
    @without_condition = Set.new
    Record.all.each do |record|
      if record.conditions.any?
        @with_condition.add(record)
        record.conditions.each do |cond|
          unless cond['codes']['SNOMED-CT'].nil?
            @key = cond['codes']['SNOMED-CT'][0]
            @counts.has_key?(@key) ? @counts[@key] += 1 : @counts[@key] = 1
            @conditions[@key] = {'count' => @counts[@key], 'name' => cond['description'] }
          end
        end
      else
        @without_condition.add(record)
      end
    end

    return @conditions, @with_condition, @without_condition
  end

  def self.no_encounters_within(days)
    @patients = Record.where({ 'encounters.time' => { "$lte" => Time.now.to_i - days.days.to_i  }})
    return @patients
  end
  def self.is_numeric?(s)
    !!Float(s) rescue false
  end

  def self.get_patients_with_medication(param)
    if self.is_numeric?(param)
        return Record.all(conditions:{"medications.codes.RxNorm" => param})
    end
  end
  
  def self.get_patients_with_condition(param)
    if self.is_numeric?(param)
      return Record.all(conditions:{"conditions.codes.SNOMED-CT" => param})
    end

    return Record.all(conditions:{"conditions.description" => param})
  end

  def self.get_race_groups
    @groups = Hash.new()
    Race.all.each do |record|
      @groups[record.name] = record.codes
    end
    return @groups
  end
  
  #note that records have a race and ethnicity code
  def self.get_races
    @groups = self.get_race_groups
    @counts = Hash.new()
    Record.all.each do |record|
      @code = record.race['code']
      @groups.each_pair do |k,v|
        if v.include?(@code)
            @counts.has_key?(k) ? @counts[k] += 1 : @counts[k] = 1
        end
      end
    end
    return @counts.to_json.html_safe
  end
  
  def self.get_ages
    @age_males = Hash.new()
    @age_females = Hash.new()

    count_gender = Proc.new do |age, gender|
        if gender == 'M'
            @age_males.has_key?(age) ? @age_males[age] +=1 : @age_males[age] = 1
        end

        if gender == 'F'
            @age_females.has_key?(age) ? @age_females[age] +=1 : @age_females[age] = 1
        end
    end
    
    @ages = Hash.new()
    @age_groups = Hash[
      "0-10" => 0,
      "11-18" => 0,
      "19-25" => 0,
      "26-35" => 0,
      "36-45" => 0,
      "46-55" => 0,
      "56-65" => 0,
      "66-75" => 0,
      "76+" => 0 ]
    
    Record.all.each do |record|
      @diff = distance_of_time_in_words_to_now(Time.at(record.birthdate))
      @age = /\d+/.match(@diff)[0]
      @gender = record.gender
      @ages.has_key?(@age) ? @ages[@age] += 1 : @ages[@age] = 0

      #is there a better way to do this in ruby
      case @age.to_i
      when 0..10
        @age_groups["0-10"] += 1
        count_gender.call('0-10', @gender)
      when 10..18
        @age_groups["11-18"] += 1
        count_gender.call('11-18', @gender)
      when 19..25
        @age_groups["19-25"] += 1
        count_gender.call('19-25', @gender)
      when 26..35
        @age_groups["26-35"] += 1
        count_gender.call('26-35', @gender)
      when 36..45
        @age_groups["36-45"] += 1
        puts "found 1", @gender
        count_gender.call('36-45', @gender)
      when 46..55
        @age_groups["46-55"] += 1
        count_gender.call('46-55', @gender)
      when 56..65
        @age_groups["56-65"] += 1
        count_gender.call('56-65', @gender)
      when 66..75
        @age_groups["66-75"] += 1
        count_gender.call('66-75', @gender)
      else 
        @age_groups["76+"] += 1
        count_gender.call('76+', @gender)
      end
    end
    puts @age_females
    return @ages.to_json.html_safe, @age_groups.to_json.html_safe, @age_males.to_json.html_safe, @age_females.to_json.html_safe
  end 
  
  def self.update_or_create(data)
    existing = Record.by_patient_id(data['patient_id']).first
    if existing
      existing.update_attributes!(data)
      existing
    else
      Record.create!(data)
    end
  end
  
  def providers
    provider_performances.map{|pp| pp.provider }
  end
  
  private 
  
  def self.provider_queries(provider_id, effective_date)
   {'$or' => [provider_query(provider_id, effective_date,effective_date), provider_query(provider_id, nil,effective_date), provider_query(provider_id, effective_date,nil)]}
  end
  def self.provider_query(provider_id, start_before, end_after)
    {'provider_performances' => {'$elemMatch' => {'provider_id' => provider_id, 'start_date'=> {'$lt'=>start_before}, 'end_date'=> {'$gt'=>end_after} } }}
  end
  
end
