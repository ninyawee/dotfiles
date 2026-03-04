# Thai Accounting DBF Table Schemas

Common table schemas found in Thai legacy accounting systems (AllInOne, Express, etc.)

## Customer/Vendor Master

### ARMST - Customer Master (ลูกหนี้)

| Field | Type | Description |
|-------|------|-------------|
| ACCID | C(10) | Customer code |
| GACCID | C(2) | Group code |
| GLID | C(15) | GL account |
| COMP | C(70) | Company name |
| NAME | C(50) | Contact name |
| ADDR1-4 | C(50) | Address lines |
| TEL | C(30) | Phone |
| FAX | C(30) | Fax |
| TAXID | C(17) | Tax ID |
| CREDITDAY | N | Credit days |
| CREDITAMT | N | Credit limit |

### APMST - Vendor Master (เจ้าหนี้)

| Field | Type | Description |
|-------|------|-------------|
| ACCID | C(10) | Vendor code |
| GACCID | C(2) | Group code |
| GLID | C(15) | GL account |
| COMP | C(70) | Company name |
| NAME | C(50) | Contact name |
| ADDR1-4 | C(50) | Address lines |
| TEL | C(30) | Phone |

## Transactions

### ARTR - AR Transactions (รายการลูกหนี้)

| Field | Type | Description |
|-------|------|-------------|
| DOCNO | C(15) | Document number |
| DATEDOC | D | Document date |
| DUEDATE | D | Due date |
| ACCID | C(10) | Customer code |
| SALEID | C(10) | Salesperson |
| TAXTYPE | C(1) | Tax type |
| VAT | N | VAT rate |
| VATAMT | N | VAT amount |
| AMOUNT_B | N | Amount before VAT |
| AMOUNT_A | N | Amount after VAT |
| PAID | N | Paid amount |
| BALANCE | N | Balance |

### APTR - AP Transactions (รายการเจ้าหนี้)

Similar structure to ARTR for vendor transactions.

### GLTR - General Ledger Transactions

| Field | Type | Description |
|-------|------|-------------|
| DOCNO | C(15) | Document number |
| DATEDOC | D | Date |
| GLID | C(15) | GL account |
| DEBIT | N | Debit amount |
| CREDIT | N | Credit amount |
| REMARK | C(50) | Description |

### GLTRHD - GL Transaction Headers

| Field | Type | Description |
|-------|------|-------------|
| DOCNO | C(15) | Document number |
| DATEDOC | D | Date |
| DOCTYPE | C(2) | Document type |
| REMARK | C(100) | Description |
| POSTFLAG | L | Posted flag |

## Inventory

### INVLOC - Inventory by Location

| Field | Type | Description |
|-------|------|-------------|
| PCODE | C(20) | Product code |
| LOCID | C(10) | Location code |
| QTY | N | Quantity |
| COST | N | Unit cost |
| AMOUNT | N | Total amount |

### INVMST - Inventory Master

| Field | Type | Description |
|-------|------|-------------|
| PCODE | C(20) | Product code |
| PNAME | C(50) | Product name |
| UNIT | C(10) | Unit |
| PGROUP | C(10) | Product group |
| COST | N | Cost |
| PRICE1-5 | N | Price levels |

## Payments

### ARPAY - AR Payments

| Field | Type | Description |
|-------|------|-------------|
| DOCNO | C(15) | Payment document |
| DATEDOC | D | Payment date |
| ACCID | C(10) | Customer code |
| INVNO | C(15) | Invoice number |
| PAYAMT | N | Payment amount |
| DISC | N | Discount |

### APPAY - AP Payments

Similar structure to ARPAY for vendor payments.

## Common Patterns

### ID Fields
- `ACCID` - Account/Customer/Vendor ID
- `GLID` - GL Account ID
- `PCODE` - Product Code
- `DOCNO` - Document Number
- `SALEID` - Salesperson ID

### Date Fields
- `DATEDOC` - Document date
- `DUEDATE` - Due date
- `POSTDATE` - Posting date

### Amount Fields
- `AMOUNT_B` - Amount before VAT
- `AMOUNT_A` - Amount after VAT
- `VATAMT` - VAT amount
- `DEBIT` / `CREDIT` - GL amounts

### Flags
- `POSTFLAG` - Posted to GL
- `CANCEL` - Cancelled
- `APPROVE` - Approved
