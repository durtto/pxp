--------------- SQL ---------------

CREATE OR REPLACE FUNCTION param.ft_alarma_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Parametros Generales
 FUNCION: 		param.ft_alarma_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'param.talarma'
 AUTOR: 		 (fprudencio)
 FECHA:	        18-11-2011 11:59:10
 COMENTARIOS:	         
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_alarma	integer;  
    v_registros_config		record;
    v_registros_detalle		record;
    v_dif_dias				integer;
    v_id_funcionario		integer;
    v_id_subsistema			integer;
    v_consulta_config	    text;
    v_consulta_detalle		text;
    --Ids que se necesitan para  SAJ
    v_id_rpc				integer;
    v_id_sup    			integer;
    v_id_rep_legal			integer; 
    v_id_sup_boleta			integer;
			    
BEGIN           

    v_nombre_funcion = 'param.ft_alarma_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'PM_ALARM_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		fprudencio	
 	#FECHA:		18-11-2011 11:59:10
	***********************************/

	if(p_transaccion='PM_ALARM_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into param.talarma(
			acceso_directo,
			id_funcionario,
			fecha,
			estado_reg,
			descripcion,
			id_usuario_reg,
			fecha_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.acceso_directo,
			v_parametros.id_funcionario,
			v_parametros.fecha,
			'activo',
			v_parametros.descripcion,
			p_id_usuario,
			now()::date,
			null,
			null
			)RETURNING id_alarma into v_id_alarma;
               
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Alarmas almacenado(a) con exito (id_alarma'||v_id_alarma||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_alarma',v_id_alarma::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;
        
        	/*********************************    
 	#TRANSACCION:  'PM_ALARM_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		fprudencio	
 	#FECHA:		18-11-2011 11:59:10
	***********************************/

	elsif(p_transaccion='PM_ALARM_MOD')then

		begin
			--Sentencia de la modificacion
			update param.talarma set
			acceso_directo = v_parametros.acceso_directo,
			id_funcionario = v_parametros.id_funcionario,
			fecha = v_parametros.fecha,
			descripcion = v_parametros.descripcion,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now()
			where id_alarma=v_parametros.id_alarma;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Alarmas modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_alarma',v_parametros.id_alarma::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;


	/*********************************    
 	#TRANSACCION:  'PM_DESCCOR_MOD'
 	#DESCRIPCION:	DEsactiva envio de correos
 	#AUTOR:		rarteaga	
 	#FECHA:		8-3-2012 11:59:10
	***********************************/

	elsif(p_transaccion='PM_DESCCOR_MOD')then

		begin
			--Sentencia de la modificacion
			 update param.talarma 
             set sw_correo = 1
             where sw_correo = 0;
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Desactiva envio de correo para alarmas'); 
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'PM_ALARM_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		fprudencio	
 	#FECHA:		18-11-2011 11:59:10
	***********************************/

	elsif(p_transaccion='PM_ALARM_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from param.talarma
            where id_alarma=v_parametros.id_alarma;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Alarmas eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_alarma',v_parametros.id_alarma::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

EXCEPTION
				
	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;
				        
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;