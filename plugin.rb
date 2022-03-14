# frozen_string_literal: true

# name: discourse-password-purgatory
# about: Password purgatory in Discourse! (Meant for April fools only)
# version: 0.1
# author: Wolftallemo
# url: https://github.com/Wolftallemo/discourse-password-purgatory

enabled_site_setting :enable_password_purgatory

after_initialize do
  module ::DiscoursePasswordPurgatory
    class PasswordValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return unless record.password_validation_required?
        return if Random.rand(99) > SiteSetting.password_purgatory_chance - 1

        checks = [
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/Homer|Marge|Bart|Lisa|Maggie/) },
            msg: I18n.t("password_purgatory.errors.simpsons")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/[ÅåÄäÖöÆæØø]/) },
            msg: I18n.t("password_purgatory.errors.nordic")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/[\u0370-\u03ff\u1f00-\u1fff]/) },
            msg: I18n.t("password_purgatory.errors.greek")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/Peter|Lois|Chris|Meg|Brian|Stewie/) },
            msg: I18n.t("password_purgatory.errors.griffin")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/:‑\)|:\)|:\-\]|:\]|:>|:\-\}|:\}|:o\)\)|:\^\)|=\]|=\)|:\]|:\->|:>|8\-\)|:\-\}|:\}|:o\)|:\^\)|=\]|=\)|:‑D|:D|B\^D|:‑\(|:\(|:‑<|:<|:‑\[|:\[|:\-\|\||>:\[|:\{|:\(|;\(|:\'‑\(|:\'\(|:=\(|:\'‑\)|:\'\)|:"D|:‑O|:O|:‑o|:o|:\-0|>:O|>:3|;‑\)|;\)|;‑\]|;\^\)|:‑P|:\-\/|:\/|:‑\.|>:|>:\/|:|:‑\||:\||>:‑\)|>:\)|\}:‑\)|>;‑\)|>;\)|>:3|\|;‑\)|:‑J|<:‑\||~:>/) },
            msg: I18n.t("password_purgatory.errors.emoticon")
          },
          {
            passwd_valid: Proc.new { |passwd|
              num = 0
              matches = passwd.match(/\d/)
              return if matches.nil?
              matches.to_a.each { |match| num += match.to_i }
              num % 3  === 0
            },
            msg: I18n.t("password_purgatory.errors.divisible_by_3")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/\d{5}(-\d{4})?/) },
            msg: I18n.t("password_purgatory.errors.zip_code")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/[ÄÜÖẞ]/) },
            msg: I18n.t("password_purgatory.errors.german_umlaut")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/dog$/) },
            msg: I18n.t("password_purgatory.errors.end_with_dog")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/^cat/) },
            msg: I18n.t("password_purgatory.errors.start_with_cat")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(
              /Luna|Deimos|Phobos|Amalthea|Callisto|Europa|Ganymede|Io|Dione|Enceladus|Hyperion|Iapetus|Mimas|Phoebe|Rhea|Tethys|Titan|Ariel|Miranda|Oberon|Titania|Umbriel|Nereid|Triton|Charon|Himalia|Carme|Ananke|Adrastea|Elara|Adrastea|Elara|Epimetheus|Callirrhoe|Kalyke|Thebe|Methone|Kiviuq|Ijiraq|Paaliaq|Albiorix|Erriapus|Pallene|Polydeuces|Bestla|Daphnis|Despina|Puck|Carpo|Pasiphae|Themisto|Cyllene|Isonoe|Harpalyke|Hermippe|Iocaste|Chaldene|Euporie/
            ) },
            msg: I18n.t("password_purgatory.errors.satellite")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/(?:[^1234569]*[1234569]){3}[^1234569]*/) },
            msg: I18n.t("password_purgatory.errors.pi")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/cockatiel/) },
            msg: I18n.t("password_purgatory.errors.cockatiel")
          },
          {
            passwd_valid: Proc.new { |passwd| passwd.match?(/Rick Astley/) },
            msg: I18n.t("password_purgatory.errors.rick_astley")
          }
        ]

        message = I18n.t("password_purgatory.errors.generic")
        failing_checks = checks.select { |check| check[:passwd_valid].(value) == false }

        if failing_checks.length > 0
          selection = failing_checks.sample
          message = selection[:msg]
        end

        record.errors.add(attribute, message)
      end
    end

    class ::User
      validate :password_purgatory
      def password_purgatory
        DiscoursePasswordPurgatory::PasswordValidator.new(attributes: :password).validate_each(self, :password, @raw_password)
      end
    end
  end
end
