CLASS zhs_cl_main_booking DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhs_cl_main_booking IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DELETE FROM zhs_t_booking.

    INSERT zhs_t_booking FROM (
        SELECT
          FROM /dmo/booking AS booking
            INNER JOIN zhs_t_travel AS z ON booking~travel_id = z~travel_id
          FIELDS
            uuid( )                 AS booking_uuid   ,
            z~travel_uuid           AS travel_uuid    ,
            booking~booking_id      AS booking_id     ,
            booking~booking_date    AS booking_date   ,
            booking~customer_id     AS customer_id    ,
            booking~carrier_id      AS carrier_id     ,
            booking~connection_id   AS connection_id  ,
            booking~flight_date     AS flight_date    ,
            booking~flight_price    AS flight_price   ,
            booking~currency_code   AS currency_code  ,
            z~created_by            AS created_by     ,
            z~last_changed_by       AS last_changed_by,
            z~last_changed_at       AS local_last_changed_by
      ).

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      out->write( 'Booking demo data inserted.' ).

    ELSE.
      ROLLBACK WORK.
      out->write( 'Booking demo data not inserted.' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
