require_relative("./lib/test_automation")
TestAutomation.configure(
  [
    {
      origin: Rails.root.join('app', 'models'),
      destination: Rails.root.join('spec', 'models'),
      strategy: :model_strategy,
      options: :rewritte_all
    }
  ]
)
