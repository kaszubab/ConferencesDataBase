create trigger ConferenceCancellation
    on Conferences
    after update
    as
    begin
        if update(Is_Cancelled)
        begin
            if (select Is_Cancelled from inserted) = 1
            begin
                declare @daysToCancel table (
                        dayID int
                )
                insert into @daysToCancel
                select Conference_Day_ID
                from u_kaszuba.dbo.Conference_Day
                where Conference_Day.Conference_ID = (select Conference_ID from inserted)

                update u_kaszuba.dbo.Conference_Day
                set Is_Cancelled = 1
                where Conference_Day_ID in @daysToCancel

            end
        end
    end

create trigger ConferenceDayCancellation
    on u_kaszuba.dbo.Conference_Day
    after update
    as
    begin
        if update(Is_Cancelled)
            begin
                if (select  Is_Cancelled from inserted) = 1
                begin

                    declare @reservationsToCancel table (
                        reservationID int
                    )
                    insert into @reservationsToCancel
                    select Reservation_ID
                    from u_kaszuba.dbo.Reservation
                    where Reservation.Conference_Day_ID = (select Conference_Day_ID from inserted)

                    update u_kaszuba.dbo.Reservation
                    set Is_Cancelled = 1
                    where Reservation_ID in @reservationsToCancel

                end
            end

    end


create trigger ReservationCancellation
    on u_kaszuba.dbo.Reservation
    after update
    as
    begin
        if update(Is_Cancelled)
        begin
            if (select Is_Cancelled from inserted) = 1
            begin

                delete from Conference_Day_Participants --remove all people with this reservation from participants list
                where Reservation_ID = (select Reservation_ID from inserted)

                declare @workshopReservationsToCancel table (
                    workshopReservationID int
                )
                insert into @workshopReservationsToCancel
                select Workshop_Reservation_ID
                from u_kaszuba.dbo.Workshop_reservation
                where Workshop_reservation.Reservation_ID = (select Reservation_ID from inserted)

                update u_kaszuba.dbo.Workshop_reservation
                set Is_Cancelled = 1
                where Workshop_Reservation_ID in @workshopReservationsToCancel

            end
        end
    end


create trigger WorkshopReservationCancellation
    on Workshop_reservation
    after update
    as
    begin
        if update(Is_Cancelled)
        begin
            if (select Is_Cancelled from inserted) = 1
            begin

                delete from Workshops_Participants --remove all people with this reservation from participants list
                where Workshop_Reservation_ID = (select Workshop_Reservation_ID from inserted)

            end
        end
    end