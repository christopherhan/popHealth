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
  
  def self.get_ages
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
      
      @ages.has_key?(@age) ? @ages[@age] += 1 : @ages[@age] = 0

      case @age.to_i
      when 0..10
        @age_groups["0-10"] += 1
      when 10..18
        @age_groups["11-18"] += 1
      when 19..25
        @age_groups["19-25"] += 1
      when 26..35
        @age_groups["26-35"] += 1
      when 36..45
        @age_groups["36-45"] += 1
      when 46..55
        @age_groups["46-55"] += 1
      when 56..65
        @age_groups["56-65"] += 1
      when 66..75
        @age_groups["66-75"] += 1
      else 
        @age_groups["76+"] += 1
      end
    end
    
    return @ages, @age_groups
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
