/** v1.4 roles — owner counted in plan member limit */
export const ROLES = [
  { id: "owner", label: "Owner", level: 100, canInvite: true },
  { id: "manager", label: "Manager", level: 80, canInvite: false },
  { id: "head_waiter", label: "Waiter Head", level: 60, canInvite: false },
  { id: "waiter", label: "Waiter/Staff", level: 40, canInvite: false }
];

export const INVITE_ROLES = ["manager", "head_waiter"];

export const DEFAULT_PERMISSIONS = {
  manager: {
    manageBookings: true,
    managePayments: true,
    manageCustomers: true,
    manageReports: true,
    managePackages: false,
    manageTeam: false
  },
  head_waiter: {
    manageBookings: false,
    viewAssignedEvents: true,
    updateOperationalStatus: true,
    managePayments: false
  }
};
