import { LightningElement, wire, api, track } from "lwc";
import getAccountUsers from "@salesforce/apex/BigBrainController.getAccountUsers";

const columns = [
  { label: "Name", fieldName: "name", sortable: true },
  { label: "Type", fieldName: "type", sortable: true },
  { label: "Email", fieldName: "email", sortable: true },
  { label: "Title", fieldName: "title", sortable: true },
  { label: "Last seen", fieldName: "last_seen", type: "date", sortable: true },
  { label: "Phone", fieldName: "phone" },
  { label: "Seniority", fieldName: "seniority" },
  {
    label: "Engagements",
    fieldName: "engagments",
    type: "number",
    sortable: true
  },
  { label: "Enabled", fieldName: "enabled", type: "boolean", sortable: true }
];

const getKind = ({ is_admin, user_kind }) => {
  if (is_admin === 1) {
    return "admin";
  } else if (user_kind === "view_only") {
    return "viewer";
  } else {
    return user_kind;
  }
};

const parseData = (data) =>
  JSON.parse(data).map((u) => ({
    name: u.name,
    email: u.email,
    title: u.title,
    phone: u.phone,
    seniority: u.seniority,
    engagments: u.engagments,
    last_seen: u.last_seen,
    enabled: u.enabled === 1 ? true : false,
    type: getKind(u)
  }));

export default class BigBrainAccountUsers extends LightningElement {
  @api pulseAccountId;

  columns = columns;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;

  @track isLoading = true;
  @track data = [];
  error;

  @wire(getAccountUsers, { pulseAccountId: "$pulseAccountId" })
  data({ error, data }) {
    this.error = error;
    if (!data) return;
    this.data = parseData(data);
    this.isLoading = false;
  }

  // Used to sort the 'Age' column
  sortBy(field, reverse, primer) {
    console.log(field, reverse, primer);
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }
}