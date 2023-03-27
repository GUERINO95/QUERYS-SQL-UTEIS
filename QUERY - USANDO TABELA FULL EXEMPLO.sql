SELECT PROD.*,
(SELECT DIM.MANAGER_SENIOR FROM ARADMIN.DIM_REGRAS_PRODMAN DIM WHERE DIM.APLICACAO = PROD.APLICACAO) AS MANAGER_SENIOR,
(SELECT DIM.MANAGER FROM ARADMIN.DIM_REGRAS_PRODMAN DIM WHERE DIM.APLICACAO = PROD.APLICACAO) AS MANAGER
FROM 
(
SELECT DISTINCT
MI.CODIGO ID_MI,
DECODE (MI.STATUS,'N','FECHADO','P','ABERTO','A','ABERTO','F','FECHADO','C','CANCELADO') STATUS,
UPPER(MICLAS.DESCRICAO) TIPO_EVENTO,
UPPER((SELECT MIELE.NOME FROM PRD_TAB_ELEMENTO@PRODMAN MIELE WHERE MI.CODIGOAPLICACAO = MIELE.CODIGO)) APLICACAO,
UPPER((SELECT MIEQU.DESCRICAO FROM PRD_TAB_EQUIPE@PRODMAN MIEQU WHERE MI.EQUIPERESPONSAVELMI = MIEQU.CODIGO)) EQUIPE_RESPONSAVEL,
MI.TITULODAMI TITULO,
UPPER(MI.SOLUCAOAPLICADA) SOLUCAO_APLICADA,
UPPER(MI.COMENTARIOFECHAMENTO) COMENTARIO_FECHAMENTO,
UPPER (TO_CHAR (MI.DATAHORACADASTRO, 'mm_mon_yy')) AS MES_PUBLICACAO,
TO_CHAR (MI.DATAHORACADASTRO, 'dd/mm/yyyy') AS DIA_PUBLICACAO,
MI.DATAHORACADASTRO PUBLICADA_EM,
MI.DATAHORAINICIOIMPACTO INICIO_IMPACTO,
MI.DATAHORAFINALIMPACTO FIM_IMPACTO,
ROUND (MI.DATAHORAFINALIMPACTO - MI.DATAHORAINICIOIMPACTO, 2) TMP_IMPACTO,
CRAIZ.NOME CAUSA_CLASSIFICADA,
(SELECT MIELE.NOME FROM PRD_TAB_ELEMENTO@PRODMAN MIELE WHERE MI.CODIGOAPLICACAOADJACENTE = MIELE.CODIGO) OFENSOR,
CASE WHEN ((SELECT MIELE.NOME FROM PRD_TAB_ELEMENTO@PRODMAN MIELE WHERE MI.CODIGOAPLICACAOADJACENTE = MIELE.CODIGO))IS NULL 
    OR UPPER ((SELECT MIELE.NOME FROM PRD_TAB_ELEMENTO@PRODMAN MIELE WHERE MI.CODIGOAPLICACAOADJACENTE = MIELE.CODIGO)) = UPPER((SELECT MIELE.NOME FROM PRD_TAB_ELEMENTO@PRODMAN MIELE WHERE MI.CODIGOAPLICACAO = MIELE.CODIGO))
    THEN 'NÃO'
    ELSE 'SIM'
END OFENDIDO,
MI.INCXTTS IN_ASSOCIADO,
MI.PBXTTS PB_ASSOCIADO,
CASE    WHEN CRAIZ.NOME = 'CHANGE' AND MI.CODIGOCHANGE IS NULL THEN 'INFORMAR CHANGE'
        WHEN CRAIZ.NOME <> 'CHANGE' OR CRAIZ.NOME IS NULL  THEN 'N/A'
        ELSE MI.CODIGOCHANGE 
END CHANGE,
MI.CODIGOSDN SDN,
UPPER(MI.MI_RETROATIVA) PUBLICACAO_RETROATIVA,
DECODE(MI.QA,'0','NÃO','1','SIM') QA,
UPPER((SELECT MIREC.NOME FROM PRD_TAB_RECURSO@PRODMAN MIREC WHERE MI.CODIGORECURSOCADASTRO = MIREC.SEQUENCIAL)) RESP_ABERTURA,
DECODE (MI.CODIGOREPORTADOPOR,'31','PARCEIRO','32','PARCEIRO','33','PARCEIRO','34','PARCEIRO','35','PARCEIRO','36','PARCEIRO','9','TI - MONITORAÇÃO',
        '3','TI - MONITORAÇÃO','4','TI - MONITORAÇÃO','5','TI - MONITORAÇÃO','7','TI - MONITORAÇÃO','8','ÁREA USUÁRIA','51','TI - MONITORAÇÃO','52','PARCEIRO') REPORTADO_POR,

CASE WHEN MI.CODIGOREPORTADOPOR IN ('9', '3', '4','5','7','51')
        THEN 'PROATIVA'
        ELSE 'REATIVA'
    END MI_PROATIVA,

(select pdm.nome from pdm_causa_raiz_niveis@PRODMAN pdm where mi.causa_raiz_n1 = pdm.id) as causa_raiz_n1,
(select pdm.nome from pdm_causa_raiz_niveis@PRODMAN pdm where mi.causa_raiz_n2 = pdm.id) as causa_raiz_n2,
(select pdm.nome from pdm_causa_raiz_niveis@PRODMAN pdm where mi.causa_raiz_n3 = pdm.id) as causa_raiz_n3

FROM PRD_TAB_MI@PRODMAN MI, PRD_TAB_APLICACAO@PRODMAN MIAPP, PRD_TAB_CLASSIFICACAO@PRODMAN MICLAS, PRD_TAB_CAUSARAIZ@PRODMAN CRAIZ

WHERE MI.CODIGOCAUSARAIZ = CRAIZ.CODIGO (+)
AND MI.DISPONIBILIDADE = MICLAS.CODIGO
AND MI.DATAHORACADASTRO >= to_date ('01/11/2018 00:00:00', 'dd/mm/rrrr hh24:mi:ss')
AND MI.DATAHORACADASTRO <= to_date (substr ((sysdate -2),1,10)||' 23:59:59', 'dd/mm/rrrr hh24:mi:ss')


)PROD
WHERE APLICACAO IN (SELECT APLICACAO FROM ARADMIN.DIM_REGRAS_PRODMAN where MANAGER_SENIOR NOT IN ('AUANA MATTAR','ADILSON FREITAS', 'N/I'))