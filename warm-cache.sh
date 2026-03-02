#!/bin/bash

BASE="https://demo.mahocommerce.com"

URLS=$(docker exec php ./maho db:query "SELECT r.request_path FROM core_url_rewrite r LEFT JOIN catalog_product_entity_int v ON r.product_id = v.entity_id AND v.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'visibility' AND entity_type_id = 4) WHERE r.is_system = 1 AND r.store_id > 0 AND (r.id_path LIKE 'category/%' OR r.id_path LIKE 'product/%') AND (r.product_id IS NULL OR v.value IN (2, 3, 4)) GROUP BY r.request_path" \
  | tail -n +3 \
  | tr -d '\r' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | sed "s|^|$BASE/|")

TOTAL=$(echo "$URLS" | wc -l | tr -d ' ')
echo "Warming $TOTAL pages..."

echo "$URLS" | xargs -P 4 -I {} sh -c '
  echo "Page: $1"
  HTML=$(curl -skL "$1" 2>/dev/null)
  if echo "$HTML" | grep -q "resize/?t="; then
    IMAGES=$(echo "$HTML" | grep -oP "resize/\?t=[^\"'\''\\< ]*" | sort -u)
    echo "$IMAGES" | sed "s|^resize/|core/index/resize/|" | xargs -P 4 -I [] curl -sk -o /dev/null "'"$BASE"'/[]" 2>/dev/null
    COUNT=$(echo "$IMAGES" | wc -l | tr -d " ")
    echo "  -> $COUNT images"
  fi
' _ {}

echo "Done!"
