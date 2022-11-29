import React from "react";
import { AccountMenuProps } from "./interfaces";
import { Link } from "../link";
import { shortRevision } from "../util";
import { t } from "../i18next_wrapper";
import { ExternalUrl } from "../external_urls";
import { FilePath, Icon, Path } from "../internal_urls";
import { logout } from "../logout";

export const AdditionalMenu = (props: AccountMenuProps) => {
  return <div className="nav-additional-menu">
    <div className={"account-link"}>
      <Link to={Path.settings("account")}
        onClick={props.close("accountMenuOpen")}>
        <img width={12} height={12} src={FilePath.icon(Icon.settings_small)} />
        {t("Account Settings")}
      </Link>
    </div>
    <div className={"logs-link"}>
      <Link to={Path.logs()} onClick={props.close("accountMenuOpen")}>
        <img width={12} height={12} src={FilePath.icon(Icon.logs)} />
        {t("Logs")}
      </Link>
    </div>
    <div className={"setup-link"}>
      <Link to={Path.setup()} onClick={props.close("accountMenuOpen")}>
        <i className="fa fa-magic" />
        {t("Setup")}
      </Link>
    </div>
    <div className={"help-link"}>
      <Link to={Path.help()} onClick={props.close("accountMenuOpen")}>
        <i className="fa fa-question-circle" />
        {t("Help")}
      </Link>
    </div>
    <div className={"logout-link"}>
      <a onClick={logout(props.isStaff)} title={t("logout")}>
        <img width={12} height={12} src={FilePath.icon(Icon.logout)} />
        {t("Logout")}
      </a>
    </div>
    {props.isStaff && <div className={"logout-link"}>
      <a onClick={logout()} title={t("logout")}>
        <img width={12} height={12} src={FilePath.icon(Icon.logout)} />
        {t("Logout and destroy token")}
      </a>
    </div>}
    <div className="app-version">
      <label>{t("APP VERSION")}</label>:&nbsp;
      <a href={ExternalUrl.webAppRepo} target="_blank" rel={"noreferrer"}>
        {shortRevision().slice(0, 8)}
      </a>
    </div>
  </div>;
};
