export const SUBSCRIPTION_PLANS = [
  {
    id: "single",
    name: "Single person",
    persons: 1,
    pricePkr: 999,
    billing: "monthly"
  },
  {
    id: "team-3",
    name: "Up to 3 persons",
    persons: 3,
    pricePkr: 1799,
    billing: "monthly"
  },
  {
    id: "team-6",
    name: "Up to 6 persons",
    persons: 6,
    pricePkr: 2500,
    billing: "monthly"
  },
  {
    id: "custom",
    name: "Custom plan",
    persons: null,
    pricePkr: null,
    billing: "custom",
    requestCustom: true
  }
];
