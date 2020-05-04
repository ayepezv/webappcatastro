-- FUNCTION: catastro.f_trigger_update_excenciones_after_insert()

-- DROP FUNCTION catastro.f_trigger_update_excenciones_after_insert();

CREATE FUNCTION catastro.f_trigger_update_excenciones_after_insert()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF 
    COST 100
    ROWS 0
AS $BODY$

declare
    AVALUO_PREDIO_CALC double precision;
    DESCUENTO double precision;
    --_ID_EXCENCION integer;
begin
    BEGIN
        select db_avaluo into AVALUO_PREDIO_CALC
        from catastro.t_liquidacion
        where id_predio=new.id_predio;
        --_ID_EXCENCION=NEW.id_excencion;
		
		CASE NEW.id_excencion
 			WHEN 1 THEN   --EXCENCION TERCERA EDAD
            	DESCUENTO = 4;
 			WHEN 2 THEN   --EXCENCION DISCAPACIDAD 100% CONTROLAR AQUI LOS PREDIOS
            	DESCUENTO = AVALUO_PREDIO_CALC*(NEW.db_porcentaje/100);
 			WHEN 3 THEN   --EXCENCION INSTITUCION PUBLICA 100%
            	DESCUENTO = AVALUO_PREDIO_CALC;
            WHEN 4 THEN   --EXCENCION REBAJAS/DESCUENTOS BIESS PORCENTUAL REVISAR
            	DESCUENTO = AVALUO_PREDIO_CALC*(NEW.db_porcentaje/100);
 			WHEN 5 THEN   --EXCENCION OTROS  SIN DEFINICION ESTA PORCENTUAL
            	DESCUENTO = AVALUO_PREDIO_CALC*(NEW.db_porcentaje/100);
            WHEN 6 THEN   --NINGUNA EXCENCION 0%
            	DESCUENTO = 0;
            WHEN 13 THEN  --EXCENCION PREDIO MUNICIPAL 100%
            	DESCUENTO = AVALUO_PREDIO_CALC;
            WHEN 15 THEN  --EXCENCION PREDIO EXENCIÓN TEMPORAL BIESS TEMPORAL BASADO EN EL CAPITAL
            	DESCUENTO=AVALUO_PREDIO_CALC* (NEW.db_capital_Biess*NEW.db_porcentaje/100);
                if DESCUENTO>AVALUO_PREDIO_CALC/2 then
					DESCUENTO=AVALUO_PREDIO_CALC/2;
				end if;
            WHEN 16 THEN  --EXCENCION PREDIO NO EDIFICADO
            	DESCUENTO = 0;
            WHEN 17 THEN  --EXCENCION PREDIO LEY DE CULTOS
            	DESCUENTO = AVALUO_PREDIO_CALC*(NEW.db_porcentaje/100);
            ELSE
     			DESCUENTO = 0;
 		END CASE;
        
        -------------------------ESTABA ANTES DEL CASE ------------------------
        --if (NEW.id_excencion=15) then     ---- CONTROLAR LA EXCENCION TEMPORAL DEL BIESS PRESTAMO HIPOTECARIO
        	--DESCUENTO=AVALUO_PREDIO_CALC* (NEW.db_capital_Biess*NEW.db_porcentaje/100);
			--if DESCUENTO>AVALUO_PREDIO_CALC/2 then
				--DESCUENTO=AVALUO_PREDIO_CALC/2;
			--end if;
		--end if;
        
        --DESCUENTO=AVALUO_PREDIO_CALC*(NEW.db_porcentaje/100);
	
        UPDATE catastro.t_predio_excencion
        set db_avaluo_predio=AVALUO_PREDIO_CALC,
            db_descuento_excencion=DESCUENTO,
            db_avaluo_imponible=AVALUO_PREDIO_CALC-DESCUENTO
        WHERE id_predio=new.id_predio
            and id_excencion=new.id_excencion;            
        RETURN NEW;
    END;
end;

$BODY$;

ALTER FUNCTION catastro.f_trigger_update_excenciones_after_insert()
    OWNER TO postgres;