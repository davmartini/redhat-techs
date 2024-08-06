FROM __REGISTRY__/vulnerable-cicd/vulnerable-log4j:latest

RUN MAIN_JAR=`ls -1 /deployments/*.jar` \
 && mkdir -p /tmp/remediation/main /tmp/remediation/log4j \
 && unzip -d /tmp/remediation/main "$MAIN_JAR" \
 && LOG4J_JAR=`ls -1 /tmp/remediation/main/BOOT-INF/lib/log4j-core-*.jar` \
 && unzip -d /tmp/remediation/log4j "$LOG4J_JAR" \
 && rm /tmp/remediation/log4j/org/apache/logging/log4j/core/lookup/JndiLookup.class \
 && cd /tmp/remediation/log4j \
 && jar -0cmf META-INF/MANIFEST.MF "$LOG4J_JAR" .  \
 && cd /tmp/remediation/main \
 && jar -0cmf META-INF/MANIFEST.MF "$MAIN_JAR" . \
 && rm -rf /tmp/remediation

LABEL cve.log4shell.remediation=applied
