create or replace TRIGGER ARADMIN.USARIO_AUTORIZADO_TRG AFTER LOGON ON DATABASE DECLARE
    P_COUNT          NUMBER(1);
    V_SESSION_USER   VARCHAR2(100) := '';
    V_OS_USER        VARCHAR2(100) := '';
    V_HOST           VARCHAR2(100) := '';
    V_EMAIL          VARCHAR2(1) := '0';

BEGIN

    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER')
      INTO V_SESSION_USER
      FROM DUAL;

    SELECT TRIM(UPPER(SYS_CONTEXT('USERENV', 'OS_USER')))
      INTO V_OS_USER
      FROM DUAL;

    SELECT SYS_CONTEXT('USERENV', 'HOST')
      INTO V_HOST
      FROM DUAL;

    SELECT COUNT(1)
      INTO P_COUNT
      FROM TB_USER_AUTORIZADO
     WHERE UPPER(TERMINAL) = UPPER(V_HOST)
        OR 'INTERNAL\' || UPPER(TERMINAL) = UPPER(V_HOST);

    IF P_COUNT = 0 AND V_SESSION_USER NOT IN ('SYS') THEN
       SELECT COUNT(1)
         INTO P_COUNT
         FROM TB_BLOQUEIO_LOGON
        WHERE DATA_LOGON > SYSDATE - 1 / 24
          AND UPPER(SCHEMANAME) = UPPER(V_SESSION_USER)
          AND UPPER(OSUSER) = UPPER(V_OS_USER)
          AND UPPER(TERMINAL) = UPPER(V_HOST);

       IF P_COUNT = 0 THEN
          PC_ENVIA_EMAIL('brumendes@timbrasil.com.br, 
		                  afacosta@timbrasil.com.br, 
						  jcricca_capgemini@timbrasil.com.br, 
						  rhoshino@timbrasil.com.br',
						  'Acesso Nao Autorizado',
						  'Usuario: '
                                || REPLACE(V_SESSION_USER, '\', '\\')
                                || '<BR>Maquina: '
                                || REPLACE(V_HOST, '\', '\\')
                                || '<BR>Matricula: '
                                || REPLACE(V_OS_USER, '\', '\\'));

       END IF;

       INSERT INTO TB_BLOQUEIO_LOGON (SCHEMANAME,
                                      OSUSER,
                                      TERMINAL,
                                      DATA_LOGON)
                              VALUES (V_SESSION_USER,
                                      V_OS_USER,
                                      V_HOST,
                                      SYSDATE
                                      );

       COMMIT;
        
       RAISE_APPLICATION_ERROR(-20010, 'USUÁRIO NÃO AUTORIZADO. Favor entrar em contato através: DL_IT_OPS_CSISLM@timbrasil.com.br');

    END IF;

    INSERT INTO tb_sucesso_logon (SCHEMANAME,
                                  OSUSER,
                                  TERMINAL,
                                  DATA_LOGON)
                          VALUES (V_SESSION_USER,
                                  V_OS_USER,
                                  V_HOST,
                                  SYSDATE
                                  );

    COMMIT;

END;