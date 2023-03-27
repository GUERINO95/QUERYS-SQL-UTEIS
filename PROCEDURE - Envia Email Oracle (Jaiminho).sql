create or replace PROCEDURE Pc_Envia_Email (
    Destino   VARCHAR2,
    Assunto   VARCHAR2,
    Corpo     VARCHAR2
) AS

    Req        Utl_Http.Req;
    Res        Utl_Http.Resp;
    Url        VARCHAR2(300) := 'http://sneppbi07v:8088/smo/jaiminho';
    Buffer     VARCHAR2(4000);
    V_Params   VARCHAR2(4000) := '';
BEGIN
    INSERT INTO Tb_Email_Enviado (
        Destino,
        Assunto,	
        Email,
        Dt_Envio
    ) VALUES (
        Destino,
        Translate(Assunto, '¿¿¿¿YÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ\', 'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy-'
                ),
       Translate(Corpo, '¿¿¿¿YÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ', 'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')
                ,
        SYSDATE
    );

    COMMIT;
    V_Params   := '{"mail" : "'
                || Destino
                || '", "subject" : "'
                || Translate(Assunto, '¿¿¿¿YÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ\', 'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy-'
                )
                || '", "msg" : "'
                || Translate(Corpo, '¿¿¿¿YÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ', 'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')

                || '"}';

    Req        := Utl_Http.Begin_Request(Url, 'POST', 'HTTP/1.1');
    Utl_Http.Set_Header(Req, 'user-agent', 'mozilla/4.0');
    Utl_Http.Set_Header(Req, 'content-type', 'application/json');
    Utl_Http.Set_Header(Req, 'Content-Length', Length(V_Params));
    Utl_Http.Write_Text(Req, V_Params);
    Res        := Utl_Http.Get_Response(Req);
    BEGIN
        LOOP Utl_Http.Read_Line(Res, Buffer);
        END LOOP;
        Utl_Http.End_Response(Res);
    EXCEPTION
        WHEN Utl_Http.End_Of_Body THEN
            Utl_Http.End_Response(Res);
    END;

END;