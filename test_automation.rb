require_relative("./lib/test_automation")
TestAutomation.configure(
  {
    load_path: Rails.root.join('strategies'),
    strategies:
      [
        {
          origin: Rails.root.join('app', 'models'),
          destination: Rails.root.join('spec', 'models'),
          strategy: :model_strategy,
          options: :rewritte_all
        }
      ]
  }
)
