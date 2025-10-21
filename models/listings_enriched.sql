{{ config(
    materialized='view',
    schema='analytics',
    alias='active_listings'
) }}

SELECT
    (l.property -> 'address') ->> 'street'      AS street,
    (l.property -> 'address') ->> 'street_2'    AS street_2,
    (l.property -> 'address') ->> 'city'        AS city,
    (l.property -> 'address') ->> 'state'       AS state,
    (l.property -> 'address') ->> 'postal_code' AS postal_code,
    (l.property -> 'address') ->> 'country'     AS country,
    (l.property ->> 'price')::numeric           AS price,
    l.created_by_id,
    l.created_at,
    (l.created_at::timestamptz AT TIME ZONE 'America/New_York') AS created_at_est,
    l.owner_id,
    l.updated_at,
    (l.updated_at::timestamptz AT TIME ZONE 'America/New_York') AS updated_at_est,
    u._id                 AS user_id,
    u.name                AS user_name,
    u.email               AS user_email,
    u.org_id              AS user_org_id,
    u.subscription_status AS user_subscription_status,
    u.clerk_dev_issuer    AS user_clerk_dev_issuer,
    o._id                 AS org_id,
    o.name                AS org_name,
    o.owner_id            AS org_owner_id,
    o.subscription_status AS org_subscription_status
FROM public.listings l
LEFT JOIN public.users u ON l.owner_id::text = u._id::text
LEFT JOIN public.orgs  o ON u.org_id::text   = o._id::text
WHERE COALESCE(u.clerk_dev_issuer, FALSE) IS NOT TRUE;
