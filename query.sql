--- get gdt_ts for domains: splitted and combined
SELECT t.name AS target, 'D'||re.domain, gr.code, pr.model, gdt_ts_4 AS gdt_ts FROM casp11.results re
    JOIN casp11.predictions pr ON re.predictions_id=pr.id 
    JOIN casp11.groups gr ON pr.groups_id = gr.id
    JOIN casp11.targets t ON pr.target::text = t.name
    JOIN casp11.domains d ON d.targets_id = t.id
  WHERE re.domain IN (1,2,12) AND gr.type IN (1,2) AND t.name SIMILAR TO 'T0%'
    AND re.domain = d.index and t.name = 'T0759'
  ORDER BY (t.name, re.domain, gr.code, pr.model)

--- get list of domains including their length and classification
SELECT t.name, 'D'||d.index, d.length, dc.name as dom_class FROM
    casp11.targets t JOIN casp11.domains d ON t.id = d.targets_id
    WHERE t.name SIMILAR TO 'T0%'
    ORDER BY (t.name, d.index)