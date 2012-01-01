class Medication
  include Mongoid::Document
  field :name, type: String
  field :rxnormId, type: String
end
