.PHONY: redis openresty
redis:
	$(MAKE) -f redis.mk $(filter-out $@,$(MAKECMDGOALS))

openresty:
	$(MAKE) -f openresty.mk $(filter-out $@,$(MAKECMDGOALS))

# prevent extra parameters error
%:
	@:
