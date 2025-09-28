.PHONY: redis
redis:
	$(MAKE) -f redis.mk $(filter-out $@,$(MAKECMDGOALS))

# prevent extra parameters error
%:
	@: