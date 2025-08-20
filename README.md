# hospital-sql-analytics



\## 🗺️ Schema (ERD)



GitHub renders Mermaid diagrams automatically.



```mermaid

erDiagram

&nbsp; PATIENTS ||--o{ APPOINTMENTS : has

&nbsp; DOCTORS  ||--o{ APPOINTMENTS : schedules

&nbsp; APPOINTMENTS ||--o{ TREATMENTS : includes

&nbsp; TREATMENTS ||--o{ BILLING : billed



&nbsp; PATIENTS {

&nbsp;   TEXT patient\_id PK

&nbsp;   TEXT first\_name

&nbsp;   TEXT last\_name

&nbsp;   TEXT gender

&nbsp;   DATE date\_of\_birth

&nbsp;   TEXT contact\_number

&nbsp;   TEXT address

&nbsp;   DATE registration\_date

&nbsp;   TEXT insurance\_provider

&nbsp;   TEXT insurance\_number

&nbsp;   TEXT email

&nbsp; }



&nbsp; DOCTORS {

&nbsp;   TEXT doctor\_id PK

&nbsp;   TEXT first\_name

&nbsp;   TEXT last\_name

&nbsp;   TEXT specialization

&nbsp;   TEXT phone\_number

&nbsp;   INT  years\_experience

&nbsp;   TEXT hospital\_branch

&nbsp;   TEXT email

&nbsp; }



&nbsp; APPOINTMENTS {

&nbsp;   TEXT appointment\_id PK

&nbsp;   TEXT patient\_id FK

&nbsp;   TEXT doctor\_id FK

&nbsp;   TIMESTAMP scheduled\_at

&nbsp;   TEXT reason\_for\_visit

&nbsp;   TEXT status

&nbsp; }



&nbsp; TREATMENTS {

&nbsp;   TEXT treatment\_id PK

&nbsp;   TEXT appointment\_id FK

&nbsp;   TEXT treatment\_type

&nbsp;   TEXT description

&nbsp;   NUMERIC cost

&nbsp;   DATE treatment\_date

&nbsp; }



&nbsp; BILLING {

&nbsp;   TEXT bill\_id PK

&nbsp;   TEXT patient\_id FK

&nbsp;   TEXT treatment\_id FK

&nbsp;   DATE bill\_date

&nbsp;   NUMERIC amount

&nbsp;   TEXT payment\_method

&nbsp;   TEXT payment\_status

&nbsp; }



