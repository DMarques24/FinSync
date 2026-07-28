-- =====================================================================
-- FinSync — índices de performance
-- =====================================================================
-- Corre isto uma vez no SQL Editor do Supabase.
--
-- Porquê: a app pagina as listas por (user_id, created_at DESC). Sem
-- índice, o Postgres tem de percorrer a tabela toda e ordenar tudo a cada
-- pedido — com poucos utilizadores nem se nota, mas com milhares de
-- linhas por pessoa o tempo de resposta cresce muito depressa.
--
-- Os índices são compostos e já na ordem certa (igualdade primeiro,
-- ordenação depois), para servirem tanto o filtro como o ORDER BY sem
-- ordenação adicional.
--
-- CONCURRENTLY evita bloquear escritas enquanto o índice é criado, o que
-- importa se já tiveres utilizadores reais. Nota: não pode correr dentro
-- de uma transação — se o editor der erro por causa disso, tira o
-- CONCURRENTLY (a app é pequena, cria num instante).
-- =====================================================================

-- Despesas: listagem paginada na Home e no gráfico de categorias.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_expenses_user_created
  ON public.expenses (user_id, created_at DESC);

-- Desejos: listagem paginada no ecrã de objetivos.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_desires_user_created
  ON public.desires (user_id, created_at DESC);

-- Eventos de calendário: filtrados por user e ordenados por data do
-- evento (não por created_at), tanto no calendário como no PDF.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_calendar_events_user_date
  ON public.calendar_events (user_id, event_date);

-- Perfis: procurado sempre por user_id.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_profiles_user
  ON public.profiles (user_id);

-- =====================================================================
-- Verificação: mostra os índices criados e o tamanho de cada um.
-- =====================================================================
-- SELECT indexname, indexdef, pg_size_pretty(pg_relation_size(indexname::regclass))
-- FROM pg_indexes
-- WHERE schemaname = 'public' AND indexname LIKE 'idx_%'
-- ORDER BY indexname;

-- =====================================================================
-- Confirmar que uma query usa mesmo o índice (deve dizer "Index Scan"
-- e não "Seq Scan"):
-- =====================================================================
-- EXPLAIN ANALYZE
-- SELECT * FROM public.expenses
-- WHERE user_id = '<o-teu-user-id>'
-- ORDER BY created_at DESC
-- LIMIT 30 OFFSET 0;
