package com.redhat.atomic.fruit;

import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import io.quarkus.runtime.configuration.ProfileManager;

@Path("/index.html")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RootResource {
    Logger logger = Logger.getLogger(RootResource.class);

    @ConfigProperty(name = "db.type")
    String dbType;

    @ConfigProperty(name = "quarkus.datasource.jdbc.url")
    String datasourceJdbcUrl;

    @Inject
    Template index;

    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get() {
        return index.data("dbType", dbType).data( "datasourceJdbcUrl", datasourceJdbcUrl).data("profile", ProfileManager.getActiveProfile());
    }
}