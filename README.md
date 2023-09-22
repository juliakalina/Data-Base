# **MEPhI course "Database"**

### **Real estate agency «Find your place»**

### **STACK:** SQL, PostgreSQL

#### **Trigger 1:**
When adding a new rental agreement with an extension, which contains the previous agreement, we check that the previous agreement was for the same client. If the client does not match, then there is an error and the insertion fails.

#### **Trigger 2:**
Upon receipt of payment for services from the client, outgoing payment documents (award) are issued to the manager and realtor in accordance with the assignment.

#### **Procedure 1:** Payment of rewards to the manager
The procedure is intended to determine the manager's remuneration. The procedure takes the manager’s id as an input parameter and calculates remuneration for him under those contracts for which it has not yet been paid. The payment is issued as a payment document. The amount of payments is determined by the formula as: 10% of the sales fee, 15% of the rental fee. Payments are not made for rent extensions.

#### **Procedure 2:** Lease extension
The procedure is intended to extend an expiring lease agreement. The procedure takes as input the number of the main lease document and determines the expiration date of the lease, taking into account the fact that renewal agreements may have already been issued. If the end date of the last lease document is less than 5 days later, you must issue a new lease document for half a year. Otherwise, display a message about the impossibility of renewing the contract.

#### **Requests**
1. Receive a report on realtors in the form:
Realtor's name; the number of leases it has entered into; the amount of lease agreements; number of sales contracts; the amount of sales contracts; the date and type of the last contract he entered into; the amount of payments that were paid to the realtor.
2. Get a report on the property for sale. Sort by price per meter. The report should be presented in the following form:
Region; type of housing; address; other housing data; when it was put up for sale; sold or not; price per meter; square; total price; is there other housing in this region that would be more expensive (yes/no);
3. Get a report on lease agreements that have been renewed more than three times. Provide the report in the form:
Description of housing; party to the agreement; start date of the first contract; number of contracts; last start date; last end date; Are there current contracts (yes/no); the total amount of all contracts; average price per month under contracts; price per month for the last contract; the total amount of payments to the realtor as remuneration.
4. Get a report on realtor activity by month of the previous year. The report contains 49 columns and 1 row for each employee.
The columns contain information: the number of lease agreements executed by the employee this month; the amount of remuneration for them; number of sales contracts; the amount for them. Information is displayed for each month (total 12 * 4 = 48 columns). The employee's name appears in a separate column.
5. Obtain information for all regions in the following form:
Region name, description, parent region, highest parent region in the hierarchy. You can use recursive functions.

#### **ER diagram**
![erd](https://github.com/juliakalina/Data-Base/assets/70514331/eaaa4411-d7e7-4f1f-ae03-39868f672738)

