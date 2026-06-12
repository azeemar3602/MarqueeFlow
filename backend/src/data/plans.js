/** v1.4 approved PKR subscription plans */
export const SUBSCRIPTION_PLANS = [
  {
    id: "basic",
    name: "Basic Plan",
    pricePkr: 999,
    priceMonthly: 999,
    currencyCode: "PKR",
    userLimit: 1,
    billing: "monthly",
    isRecommended: false,
    requestCustom: false,
    features: [
      "1 owner account",
      "Manage bookings",
      "Customer management",
      "Basic reports",
      "Email support"
    ]
  },
  {
    id: "standard",
    name: "Standard Plan",
    pricePkr: 1799,
    priceMonthly: 1799,
    currencyCode: "PKR",
    userLimit: 3,
    billing: "monthly",
    isRecommended: true,
    requestCustom: false,
    features: [
      "Up to 3 persons total",
      "Add Manager or Waiter Head",
      "Team collaboration",
      "Advanced reports",
      "Priority support"
    ]
  },
  {
    id: "premium",
    name: "Premium Plan",
    pricePkr: 2500,
    priceMonthly: 2500,
    currencyCode: "PKR",
    userLimit: 6,
    billing: "monthly",
    isRecommended: false,
    requestCustom: false,
    features: [
      "Up to 6 persons total",
      "Multiple team members",
      "Role permissions",
      "Advanced analytics",
      "Dedicated support"
    ]
  },
  {
    id: "custom",
    name: "Custom Plan",
    pricePkr: null,
    priceMonthly: null,
    currencyCode: "PKR",
    userLimit: null,
    billing: "custom",
    isRecommended: false,
    requestCustom: true,
    features: ["For teams above 6 persons", "Custom pricing", "Admin review"]
  }
];
