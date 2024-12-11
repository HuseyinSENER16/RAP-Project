CLASS zhs_cl_main_travel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_state,
        status      TYPE sy-msgty,
        status_text TYPE sy-msgv1,
      END OF ty_state,
      tt_zhs_r_travel TYPE TABLE OF zhs_r_travel.

    METHODS read_entity
      EXPORTING
        VALUE(e_result) TYPE tt_zhs_r_travel
      RETURNING
        VALUE(r_state)  TYPE ty_state.

    METHODS create_entity
      RETURNING
        VALUE(r_state) TYPE ty_state.

    METHODS delete_entity
      RETURNING
        VALUE(r_state) TYPE ty_state.

    METHODS modify_entity
      RETURNING
        VALUE(r_state) TYPE ty_state.

    METHODS insert_to_db
      RETURNING
        VALUE(r_state) TYPE ty_state.
ENDCLASS.



CLASS zhs_cl_main_travel IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: state TYPE ty_state.
    "Insert Data...
*    state = me->insert_to_db( ).
*    out->write( state ).

    "Reading Entity...
*    me->read_entity( IMPORTING e_result = DATA(result) ).
*    out->write( result ).

    "Modifying Entity...
*    state = me->modify_entity( ).
*    out->write( state ).

    "Creating Entity...
*    state = me->create_entity( ).
*    out->write( state ).

    "Deleting Entity...
    state = me->delete_entity( ).
    out->write( state ).
  ENDMETHOD.


  METHOD insert_to_db.
    DELETE FROM zhs_t_travel.

    INSERT zhs_t_travel FROM (
        SELECT
          FROM /dmo/travel
          FIELDS
            uuid( )      AS travel_uuid     ,
            travel_id     AS travel_id      ,
            agency_id     AS agency_id      ,
            customer_id   AS customer_id    ,
            begin_date    AS begin_date     ,
            end_date      AS end_date       ,
            booking_fee   AS booking_fee    ,
            total_price   AS total_price    ,
            currency_code AS currency_code  ,
            description   AS description    ,
            CASE status
              WHEN 'B' THEN 'A' " accepted
              WHEN 'X' THEN 'X' " cancelled
              ELSE 'O'          " open
            END           AS overall_status ,
            createdby     AS created_by     ,
            createdat     AS created_at     ,
            lastchangedby AS last_changed_by,
            lastchangedat AS last_changed_at,
            lastchangedat AS local_last_changed_at
            ORDER BY travel_id UP TO 200 ROWS
      ).

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      r_state = VALUE #( status = 'S' status_text = 'Travel demo data inserted.' ).

    ELSE.
      ROLLBACK WORK.
      r_state = VALUE #( status = 'E' status_text = 'Travel demo data not inserted.' ).
    ENDIF.
  ENDMETHOD.


  METHOD read_entity.
    READ ENTITIES OF zhs_r_travel ENTITY Travel
      ALL FIELDS WITH VALUE #( ( TravelUUID = '3337AED18FD04C311900AD62CC64C96A' ) )
      RESULT DATA(travels).

    IF travels IS NOT INITIAL.
      e_result = travels.
      r_state = VALUE #( status = 'S' status_text = 'Success..' ).
    ELSE.
      r_state = VALUE #( status = 'W' status_text = 'Warning..' ).
    ENDIF.
  ENDMETHOD.


  METHOD modify_entity.
    MODIFY ENTITIES OF zhs_r_travel ENTITY Travel
        UPDATE SET FIELDS WITH VALUE #( ( TravelUUID = '3337AED18FD04C311900AD62CC64C96A' Description = 'Huseyin SENER!' ) )
            FAILED DATA(failed)
            REPORTED DATA(reported).

    IF failed IS INITIAL.
      COMMIT ENTITIES
         RESPONSE OF zhs_r_travel
         FAILED DATA(failed_commit)
         REPORTED DATA(reported_commit).

      r_state = VALUE #( status = 'S' status_text = 'Success..' ).
    ELSE.
      r_state = VALUE #( status = 'W' status_text = 'Warning..' ).
    ENDIF.
  ENDMETHOD.


  METHOD create_entity.
    MODIFY ENTITIES OF zhs_r_travel ENTITY Travel
        CREATE SET FIELDS WITH VALUE #(
           ( %cid = 'ContentID' AgencyID = '70012' CustomerID = '14'
           BeginDate = cl_abap_context_info=>get_system_date( )
           EndDate = cl_abap_context_info=>get_system_date( ) + 10
           Description = 'Selamlar Huseyin. RAP Model' )
           )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

    IF failed IS INITIAL.
      COMMIT ENTITIES
         RESPONSE OF zhs_r_travel
         FAILED DATA(failed_commit)
         REPORTED DATA(reported_commit).

      r_state = VALUE #( status = 'S' status_text = 'Success..' ).
    ELSE.
      r_state = VALUE #( status = 'W' status_text = 'Warning..' ).
    ENDIF.
  ENDMETHOD.


  METHOD delete_entity.
    MODIFY ENTITIES OF zhs_r_travel ENTITY Travel
        DELETE FROM VALUE #(
           ( TravelUUID = '6AE38983FB421EEFACC6F2100197A207' ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

    IF failed IS INITIAL.
      COMMIT ENTITIES
         RESPONSE OF zhs_r_travel
         FAILED DATA(failed_commit)
         REPORTED DATA(reported_commit).

      r_state = VALUE #( status = 'S' status_text = 'Success..' ).
    ELSE.
      r_state = VALUE #( status = 'W' status_text = 'Warning..' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
