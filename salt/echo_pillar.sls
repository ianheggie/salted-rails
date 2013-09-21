# On the initial highstate run,
# we should see the pillar data
# contained in the Vagrantfile.

{% for pillar_key in pillar.keys() %}
echo-pillar-{{ pillar_key}}:
  cmd.run:
    - name: echo "{{ pillar_key }}"
{% endfor %}
