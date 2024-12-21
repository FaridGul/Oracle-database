CREATE TABLE Faculty
(
Faculty_ID NUMBER  primary key,
Faclty_Name VARCHAR2(50)
);

CREATE TABLE Book
(
B_SSN NUMBER PRIMARY KEY,
B_Name VARCHAR2(50) ,
B_Auther VARCHAR2(50)
);

CREATE TABLE Computer
(
    com_Num NUMBER PRIMARY KEY,
    com_name VARCHAR2(50),
    com_model NUMBER
);
alter table Computer
MODIFY com_model VARCHAR2(7);




CREATE TABLE Internet
(
    I_total_amount NUMBER,
    I_spend_amount NUMBER
);

CREATE TABLE Empolayee
(
E_ID NUMBER primary key,
E_F_Name VARCHAR2(50) not null,
E_Father_Name VARCHAR2(50) not null,
E_Salary NUMBER check (E_Salary<= 10000)  not null
);


CREATE TABLE Library
(
L_ID NUMBER primary key,
L_Name VARCHAR2(100) not null,
L_Book_No NUMBER not null,
L_computer_No NUMBER,
L_Location VARCHAR2(100) not null
);



CREATE TABLE Book_Catogory  
(
B_C_ID NUMBER primary key,
B_C_Name VARCHAR2(50) not null
);

CREATE TABLE Student
(
S_ID NUMBER primary key,
S_SSN NUMBER not null,
S_F_Name VARCHAR2(50) not null,
S_LName VARCHAR2(50),
S_Father_Name VARCHAR2(50) not null,
S_Phone NUMBER,
Taked_B_Date DATE not null,
Bring_B_Date DATE
);

CREATE TABLE Manager(
    M_ID NUMBER PRIMARY KEY,
    M_Name VARCHAR2(50),
    M_Father_name VARCHAR2(50),
    M_Salary NUMBER,
    mangment_type VARCHAR2(100)
)

-------------------------- many to many tables

create table Book_Belong
(
B_No_FK varchar2(50),
B_Catogory_IDF NUMBER 
);


create table Book_Choice
(
B_Np_FK VARCHAR2(50) ,
S_NameFK VARCHAR2(50)
);


CREATE TABLE stud_with_comp
(
    Com_NoFK NUMBER,
    S_IDFk NUMBER
);

SELECT * from BOOK
-------------------------- Constrants section --------------------------------------

alter table Library
add M_IDF NUMBER
alter table Library add constraint  manager_FK 
FOREIGN key (M_IDF) references Manager (M_ID);
SELECT * from MANAGER

alter table Student
add L_IDF NUMBER
alter table Student add constraint  Librar1_Table_FK
FOREIGN key (L_IDF) references Library (L_ID);



alter table Book_Catogory
add L_IDF NUMBER
alter table Book_Catogory add constraint  Library2_Table_FK
FOREIGN key (L_IDF) references Library (L_ID);



alter table Student 
add F_IDf NUMBER(20)
alter table Student add constraint Faculty_FK 
FOREIGN key (F_IDf) references Faculty(Faculty_ID);

alter table Empolayee 
add L_IDf NUMBER
alter table Empolayee add constraint Library_FK 
FOREIGN key (L_IDf) references Library(L_ID);


alter table Empolayee 
add M_IDf NUMBER
alter table Empolayee add constraint manager_FK 
FOREIGN key (M_IDf) references manager(M_ID);
------------------------------------------ constraints lift
alter table Book_Belong 
add  Book_FK NUMBER
alter table Book_Belong add constraint Book1_FK
FOREIGN key (Book_FK) references Book (B_SSN);

alter table Book_Belong 
add B_C_IDF NUMBER
alter table Book_Belong add constraint B_Catagory_FK
FOREIGN key (B_C_IDF) references Book_Catogory(B_C_ID);


alter table Book_Choice
add Book_IDF NUMBER
alter table Book_Choice add constraint Book_FK2
FOREIGN key (Book_IDF) references Book (B_SSN);


alter table Book_Choice 
add stu_IDF NUMBER
alter table Book_Choice add constraint Student_FK 
FOREIGN key (stu_IDF) references Student(S_ID);

alter table Book
add B_C_IDF NUMBER
alter table Book add constraint Catagory_FK 
FOREIGN key (B_C_IDF) references Book_Catogory(B_C_ID);

select * from Book

--ALTER TABLE student -----  i altered in varchar2 but the refereces was in numbe
--MODIFY F_IDf NUMBER ----- now i modify it to change into number now become executable

-------------------------------- Procedure ----------------------------------------------
---------------------- very important procedure ---------
CREATE OR REPLACE PROCEDURE Return_book(
    p_studentID IN NUMBER,
    p_BookID IN NUMBER
)
AS 
BEGIN 
    UPDATE student
    SET Bring_B_Date = SYSDATE
    WHERE student.S_ID = p_studentID;

    DELETE FROM student WHERE student.S_ID = p_studentID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE; -- rethrow the exception
END;

BEGIN
    Return_book(1, 1); -- Replace with actual student ID and book ID
END;

execute Return_book (1,1)
---- this is for student deleting when book returned
-------
CREATE OR REPLACE PROCEDURE Borrow_book(
    p_studentID IN NUMBER, 
    p_BookID IN NUMBER)
AS 
BEGIN 
    INSERT INTO Book_Choice (B_Np_FK, S_NameFK)
    VALUES (p_BookID, p_studentID);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
BEGIN
    Borrow_book(1, 5); -- Replace with actual student ID and book ID
END;
execute Borrow_book(1,5)
----------

CREATE OR REPLACE PROCEDURE Add_Book(
    p_B_SSN IN NUMBER,
    p_B_Name IN VARCHAR2,
    p_B_Auther IN VARCHAR2,
    p_B_C_IDF IN NUMBER,
    p_Category_Name IN VARCHAR2
)
AS
    v_L_computer_No NUMBER;
    v_Category_ID NUMBER;
BEGIN
    -- Insert the book into the Book table
    INSERT INTO Book (B_SSN, B_Name, B_Auther, B_C_IDF) 
    VALUES (p_B_SSN, p_B_Name, p_B_Auther, p_B_C_IDF);

    -- Increase L_computer_No in Library table by 1 (assuming incrementing by 1)
    SELECT NVL(MAX(L_computer_No), 0) + 1 INTO v_L_computer_No FROM Library;

    -- Update the Library table
    UPDATE Library SET L_computer_No = v_L_computer_No;

    -- Check if the category exists; if not, insert it
    BEGIN
        SELECT B_C_ID INTO v_Category_ID
        FROM Book_Catogory
        WHERE B_C_Name = p_Category_Name;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- If no category found, insert a new one
            INSERT INTO Book_Catogory (B_C_Name) VALUES (p_Category_Name);
            -- Get the new category ID
            SELECT B_C_ID INTO v_Category_ID FROM Book_Catogory WHERE B_C_Name = p_Category_Name;
    END;

END;

BEGIN
    Add_Book(-- p_B_SSN,p_B_Name,p_B_Auther,p_B_C_IDF,p_Category_Name
                1,'Oracle','Hemathmal',1,'Science')
END;

execute Add_Book
---------------------------

CREATE OR REPLACE PROCEDURE Add_Student(
    p_S_ID IN NUMBER,
    p_S_SSN IN NUMBER,
    p_S_F_Name IN VARCHAR2,
    p_S_LName IN VARCHAR2,
    p_S_Father_Name IN VARCHAR2,
    p_S_Phone IN NUMBER
)
AS
BEGIN
    -- Insert the new student
    INSERT INTO Student (S_ID, S_SSN, S_F_Name, S_LName, S_Father_Name, S_Phone)
    VALUES (p_S_ID, p_S_SSN, p_S_F_Name, p_S_LName, p_S_Father_Name, p_S_Phone);
END;

-------------------------------- Triggers  ----------------------------------------------
CREATE OR REPLACE TRIGGER check_book_limit
BEFORE INSERT ON Book_Choice
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Book_Choice
    WHERE stu_IDF = :NEW.stu_IDF;

    IF v_count >= 5 THEN
        RAISE_APPLICATION_ERROR(-20001, 'A student can borrow a maximum of 5 books.');
    END IF;
END;
-----------------

CREATE OR REPLACE TRIGGER trg_Audit_Student
AFTER INSERT OR UPDATE ON Student
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO Audit_Student (S_ID, Action)
        VALUES (:NEW.S_ID, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO Audit_Student (S_ID, Action)
        VALUES (:NEW.S_ID, 'UPDATE');
    END IF;
END;

-------------------------------- views ----------------------------------------------

CREATE OR REPLACE VIEW Current_Book_Loans 
AS
SELECT s.S_F_Name, s.S_LName, b.B_Name, bc.B_Np_FK
FROM Student s
JOIN Book_Choice bc ON s.S_ID = bc.S_NameFK
JOIN Book b ON bc.B_Np_FK = b.B_SSN;

SELECT * FROM Current_Book_Loans; --To view which books are currently borrowed
-------------------------------- Functions  ----------------------------------------------

CREATE OR REPLACE FUNCTION Calculate_Fine(
    p_Bring_B_Date IN DATE)
RETURN NUMBER
IS
    v_fine NUMBER := 0;
BEGIN
    IF SYSDATE > p_Bring_B_Date THEN
        v_fine := (SYSDATE - p_Bring_B_Date) * 1; -- $1 per day late
    END IF;
    RETURN v_fine;
END;

-------------------------------- indexes by each table ------------------------------------

CREATE INDEX idx_student_name ON Student(S_F_Name);
CREATE INDEX idx_book_name ON Book(B_Name);