WITH combined_sites AS (
    SELECT 'Offline' AS status, s.customer_id, s.is_active
    FROM offline_sites s
    UNION ALL
    SELECT 'Online' AS status, s.customer_id, s.is_active
    FROM online_sites s
    UNION ALL
    SELECT 'Suspended' AS status, s.customer_id, s.is_active
    FROM suspended_sites s
)
SELECT 
    cs.status,
    COUNT(cs.customer_id) AS total_sites
FROM combined_sites cs
JOIN customers c ON cs.customer_id = c.id
WHERE c.is_active = 1 
  AND cs.is_active = 1
GROUP BY cs.status
ORDER BY 
    CASE cs.status
        WHEN 'Offline' THEN 1
        WHEN 'Online' THEN 2
        WHEN 'Suspended' THEN 3
    END;