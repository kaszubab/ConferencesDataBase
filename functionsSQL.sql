CREATE FUNCTION SplitList -- Function splits list passed as an argument based on the delimiter character (useful for parsing CSV lists)
(
   @List       VARCHAR(MAX),
   @Delimiter  CHAR(1)
)
RETURNS @ResultTable TABLE (items varchar(50))
AS
BEGIN 
	declare @item varchar(8)
	declare @separatorPosition int

	if len(@List) < 1 or @List is NULL return

	select @separatorPosition = -1


	while @separatorPosition <> 0
	BEGIN
		set @separatorPosition = CHARINDEX(@Delimiter,@List,0)

		if @separatorPosition != 0
			set @item = SUBSTRING(@List,0, @separatorPosition)
		else
			set @item = @List

		if (len(@item) > 0)
		BEGIN
			Insert into @ResultTable Values (@item)
			set @List = SUBSTRING(@List, @separatorPosition+1,LEN(@List))
		END
		ELSE
			return

	END

RETURN
END


CREATE FUNCTION FreePlacesForConferenceDay(
    @conferenceDayID int
)
RETURNS int
AS
    BEGIN
        DECLARE @allPlaces int
        SET @allPlaces = (SELECT Conference_Day.Participants_Limit
            FROM Conference_Day
            WHERE Conference_Day.Conference_Day_ID = @conferenceDayID)

        DECLARE @takenPlaces int
        SET @takenPlaces = (SELECT COUNT(*)
            FROM u_kaszuba.dbo.Reservation
            WHERE Conference_Day_ID = @conferenceDayID)

        RETURN (@allPlaces - @takenPlaces)

    END


SELECT  DATEDIFF(DAY,CONVERT(date, GETDATE()),CONVERT(date, GETDATE()) )

CREATE FUNCTION SumToPay(
    @conferenceDayID int,
    @normalTicketsCount int,
    @studentTicketsCount int
)
returns MONEY
AS
    BEGIN
        DECLARE @studentDiscount DECIMAL(3,2)
        SET @studentDiscount = (SELECT Conferences.Student_Discount
            FROM Conferences
            WHERE Conferences.Conference_ID = (SELECT Conference_ID
                FROM Conference_Day
                WHERE Conference_Day_ID = @conferenceDayID))
		
		DECLARE @reservationDate  DATE
		SET @reservationDate = CONVERT(date, GETDATE())

		DECLARE @conferenceDayDate DATE = (SELECT Date
			FROM Conference_Day
			WHERE Conference_Day_ID = @conferenceDayID)

		DECLARE @DISCOUNT DECIMAL(2,2) = 0
		SET @DISCOUNT = (SELECT TOP 1 Discount_Percentage
			FROM Discounts
			WHERE Discounts.Conference_Day_ID = @conferenceDayID
			AND (DATEDIFF(DAY, @conferenceDayDate, @reservationDate)) >  Discounts.Days_Before_Conference
			ORDER BY Days_Before_Conference DESC
			)

		DECLARE @TOTAL MONEY




        --take discount percentage from Discounts but how it works with this dates?

    END