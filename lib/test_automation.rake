require_relative "folder_explorer"
require_relative "test_file"
require_relative "test_automation"


include FolderExplorer
namespace :specs do



  desc 'write tests'
  task write_tests: :environment do
    TestAutomation::Configuration.instance.options.each do |options|
      origin = options[:origin].to_s
      destination = options[:destination].to_s
      models = retrieve_filenames_without_ext(origin, Proc.new {|filename| filename.split("/")[-1][0..-4]})
      spec_models = retrieve_filenames_without_ext(destination, Proc.new{|filename| filename.split("/")[-1][0..-9]})
      diff = models - spec_models
      File.open("#{destination}/product_spec.rb", "w+") do |f|
        strategy = TestAutomation::Strategies.send(options[:strategy], Product)
        TestFile.new(f, Product, strategy).generate()
      end
    end
  end


  desc 'check factories to write'
  task factories_to_write: :environment do
    spec_folder = YAML.load_file(Rails.root.join('lib', 'tasks', 'test-automation-module', 'lib','config.yml'))["spec_folder"]
    factories_path = Rails.root.join(spec_folder, 'factories')
    models = retrieve_filenames_without_ext(Rails.root.join('app', 'models'), Proc.new {|filename| filename.split("/")[-1][0..-4]})
    factories = retrieve_filenames_without_ext(factories_path, Proc.new{|filename| filename.split("/")[-1][0..-4]})
    diff = models - factories
    puts(diff)
    puts(diff.count)
    models.each do |filename|
      File.open("#{factories_path}/#{filename}.rb", "w+") do |f|
         # override classify for scolum_data
         if filename == "scolum_data"
           FactoryFileGenerator.new(ScolumData, f).init_file_creation
         elsif filename == "geographical_data"
           FactoryFileGenerator.new(GeographicalData, f).init_file_creation
         else
           FactoryFileGenerator.new(filename.classify.constantize, f).init_file_creation
         end
      end
    end
  end
  desc 'check controllers spec to write'
  task controllers_to_write: :environment do
    spec_folder = YAML.load_file(Rails.root.join('lib', 'tasks', 'test-automation-module', 'lib','config.yml'))["spec_folder"]
    spec_controllers_path = Rails.root.join(spec_folder, 'controllers')
    File.open("#{spec_controllers_path}/articles_controller_spec.rb", "w+") do |f|
      ControllerTestFileGenerator.new(Admin::ArticlesController, f).init_test_creation
    end
    # models = retrieve_filenames_without_ext(Rails.root.join('app', 'controllers'), Proc.new {|filename| filename.split("/")[-1][0..-4]})
    # spec_models = retrieve_filenames_without_ext(spec_models_path, Proc.new{|filename| filename.split("/")[-1][0..-9]})
    # diff = models - spec_models
    # puts(diff)
    # puts(diff.count)
    # diff.each do |filename|
    #   File.open("#{spec_models_path}/#{filename}_spec.rb", "w+") do |f|
    #      # override classify for scolum_data
    #      if filename == "scolum_data"
    #        ModelTestFileGenerator.new(ScolumData, f).init_test_creation
    #      else
    #        ModelTestFileGenerator.new(filename.classify.constantize, f).init_test_creation
    #      end
    #   end
    # end
  end



  desc 'check models specs to write'
  task to_write: :environment do
    spec_folder = YAML.load_file(Rails.root.join('lib', 'tasks', 'test-automation-module', 'lib', 'config.yml'))["spec_folder"]
    spec_models_path = Rails.root.join(spec_folder, 'models')
    models = retrieve_filenames_without_ext(Rails.root.join('app', 'models'), Proc.new {|filename| filename.split("/")[-1][0..-4]})
    spec_models = retrieve_filenames_without_ext(spec_models_path, Proc.new{|filename| filename.split("/")[-1][0..-9]})
    diff = models - spec_models
    puts(diff)
    puts(diff.count)
    # diff.each do |filename|

      File.open("#{spec_models_path}/product_spec.rb", "w+") do |f|
         # override classify for scolum_data
         # if filename == "scolum_data"
         #   ModelTestFileGenerator.new(ScolumData, f).init_test_creation
         # elsif filename == "geographical_data"
         #   ModelTestFileGenerator.new(GeographicalData, f).init_test_creation
         # else
         TestFile.new(Product, f).generate()

           # ModelTestFileGenerator.new(filename.classify.constantize, f).init_test_creation
         # end
      end
    # end
  end

end
