// enum InvoiceStatus {
//   draft,
//   issued,
//   cancelled,
// }

// class InvoiceStatusSwitch {
//   final InvoiceStatus? invoiceStatusEnum;
//   final int? invoiceStatusID;

//   InvoiceStatusSwitch({
//     this.invoiceStatusEnum,
//     this.invoiceStatusID,
//   });

//   int switchID() {
//     switch (invoiceStatusEnum) {
//       case InvoiceStatus.draft:
//         return 1;
//       case InvoiceStatus.issued:
//         return 2;
//       case InvoiceStatus.cancelled:
//         return 3;
//       case null:
//         return 1;
//     }
//   }

//   InvoiceStatus switchEnum() {
//     switch (invoiceStatusID) {
//       case 1:
//         return InvoiceStatus.draft;
//       case 2:
//         return InvoiceStatus.issued;
//       case 3:
//         return InvoiceStatus.cancelled;
//       default:
//         return InvoiceStatus.draft;
//     }
//   }

//   String getText() {
//     final status = invoiceStatusEnum ?? switchEnum();

//     switch (status) {
//       case InvoiceStatus.draft:
//         return 'Draft';
//       case InvoiceStatus.issued:
//         return 'Issued';
//       case InvoiceStatus.cancelled:
//         return 'Cancelled';
//     }
//   }
// }
