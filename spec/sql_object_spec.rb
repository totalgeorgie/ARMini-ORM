require 'armini/sql_object'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Sample < SQLObject
    end

    class Demo < SQLObject
      self.table_name = 'demos'
    end
  end

  describe '::set_table/::table_name' do
    it '::set_table_name sets table name' do
      expect(Demo.table_name).to eq('demos')
    end

    it '::table_name generates default name' do
      expect(Sample.table_name).to eq('samples')
    end
  end

     describe '::columns' do
     it '::columns gets the columns from the table and symbolizes them' do
       expect(Sample.columns).to eq([:id, :name])
     end
                                                                                                                                                                
     it'::columns creates getter methods for each column' do
       Sample.columns
       s = Sample.new
       expect(s.respond_to? :nonexisting_column).to be false
       expect(s.respond_to? :id).to be true
       expect(s.respond_to? :name).to be true
     end

     it '::columns creates setter methods for each column' do
       Sample.columns
       s = Sample.new
       s.id = 999
       s.name = "Sample"
       expect(s.id).to eq 999
       expect(s.name).to eq "Sample"
     end

     it '::columns created setter methods use attributes hash to store data' do
       Sample.columns
       s = Sample.new
       s.id = 25
       s.name = "Sample"
       expect(s.instance_variables).to eq [:@attributes]
       expect(s.attributes[:id]).to eq 25
       expect(s.attributes[:name]).to eq "Sample"
     end

   end

  describe '#initialize' do
    it '#initialize properly sets values' do
      s = Sample.new(name: 'Sample', id: 100)
      expect(s.name).to eq 'Sample'
      expect(s.id).to eq 100 
    end

    it '#initialize throws the error with unknown attr' do
      expect do
        Sample.new(nmae: 'Typo column nmae')
      end.to raise_error "unknown attribute 'nmae'"
    end
  end
end