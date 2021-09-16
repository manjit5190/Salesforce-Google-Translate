import { api, LightningElement, track } from "lwc";
import translate from "@salesforce/apex/GoogleTranslateHelper.translate";
import GoogleTranslateImages from "@salesforce/resourceUrl/GoogleTranslateImages";

export default class BasicDatatable extends LightningElement {
  @api isHTML = false;
  @api languageOptions = [
    { language: "English", code: "en" },
    { language: "French", code: "fr" }
  ];
  @api inputText = "Hello Manjit! How are you doing?";

  currentLanguageCode;
  translatedLanguageCode;
  isLoading = false;

  @track _translationResponse;

  get attributionImage() {
    return GoogleTranslateImages + "/attribution.svg";
  }

  get translateButtonLabel() {
    let selected = this.languageOptions.filter((item) => {
      return item.code === this.currentLanguageCode;
    });
    return selected[0].language;
  }

  get languageMenuItems() {
    return this.languageOptions
      .filter((item) => {
        return item.code !== this.currentLanguageCode;
      })
      .map((item) => {
        return {
          label: item.language,
          value: item.code
        };
      });
  }

  get translatedValue() {
    if (
      this._translationResponse &&
      Array.isArray(this._translationResponse["translatedText"])
    ) {
      return this._translationResponse["translatedText"][0];
    }
    return this.inputText;
  }

  connectedCallback() {
    this.currentLanguageCode = this.languageOptions[0].code;
  }

  handleTranslate(event) {
    this.isLoading = true;
    this.translatedLanguageCode = event.detail.value;
    this.translateJS()
      .then((result) => {
        this._translationResponse = result;
        this.currentLanguageCode = this.translatedLanguageCode;
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  @api
  async translateJS() {
    let result = await translate({
      input: JSON.stringify({
        textToBeTranslated: [this.inputText],
        isHTML: this.isHTML,
        fromLanguage: this.translatedLanguageCode,
        toLanguage: this.currentLanguageCode
      })
    });
    return JSON.parse(`${result}`);
  }
}
