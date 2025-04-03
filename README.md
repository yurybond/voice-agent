# Voice Assistant on Agentforce




##Manual Configuration


1. Setup->User Interface->Enable Address Field->Save
<img width="1010" alt="Screenshot 2025-03-20 at 17 48 49" src="https://github.com/user-attachments/assets/7e01135d-b372-4b44-a1b7-7fd47bc59124" />



## Data Model

```mermaid
  info
```

``````mermaid
erDiagram
    Account ||--o{ Contact : "has"
    Contact ||--o{ Route : "has"
    Route ||--o{ Stop : "has"
    Stop ||--o| Facility : "located_at"

    Account {
        String Name
        String Type
        String Industry
    }

    Contact {
        String FirstName
        String LastName
        String Email
        Phone Phone
        Lookup AccountId
    }

    Route {
        String Name
        String Status__c
        Lookup Contact__c
    }

    Stop {
        String Name
        Decimal Sequence_Number__c
        DateTime Expected_Arrival_Start_Time__c
        DateTime Expected_Arrival_End_Time__c
        DateTime Expected_Departure_Time__c
        Picklist Trip__c
        Lookup Route__c
        Lookup Facility__c
    }

    Facility {
        String Name
        String Address__City__s
        String Address__StateCode__s
        String Address__Street__s
        String Address__PostalCode__s
        String Address__CountryCode__s
        Lookup Account__c
    }
```